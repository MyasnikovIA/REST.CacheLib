///     <script language="JavaScript" type="text/javascript" src="http://localhost:57772/<-WebApp->/<-namespace->"></script>
///     <script language="JavaScript" type="text/javascript" src="http://localhost:57772/<-WebApp->/<-namespace->/User.test"></script>
/// 
///  <pre>
///  Class User.testRest Extends %CSP.Page
///  {
///  ClassMethod OnPage() As %Status
///  {
///  	&html<
///  <html>
///   <head>
///     <script language="JavaScript" type="text/javascript" src="http://localhost:57772/android"></script>
///     <script language="JavaScript" type="text/javascript" src="http://localhost:57772/android/User.test"></script>
///     <script language="JavaScript">
///      callBack=function(txt){
///  	    alert('callBack:'+txt)
///      }
///   
///      ProgressBack=function(txt){
///  	    alert('ProgressBack:'+txt)
///      }
///      
///      test=function(){
///  	    run('www',callBack,ProgressBack)
///      }  
///    </script>
///  </head>
///  <body>
///      <button onclick="console.log(GetServer('User.test.run','www'))"> run 2</button>
///      <button onclick="test()"> run 2</button>
///  </body>
///  </html>
///  >
///  	Quit $$$OK
///  }
///  }
///  </pre>
/// 
///  Export:
///    d $SYSTEM.OBJ.ExportUDL("REST.CacheLib.cls","D:\Python\webServer\REST.CacheLib.cls")	 
Class REST.CacheLib Extends %CSP.REST
{

Parameter GlobalMessage = "^mtempREST.CacheLib.js";

Parameter UseSession As BOOLEAN = 0;

Parameter intervalQueryStatus = 500;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/:namespace/:classname" Method="POST" Call="RunClassMethod"/>
<Route Url="/:namespace/:classname/job" Method="POST" Call="JobClassMethod"/>
<Route Url="/:namespace/:classname/job/:processid" Method="GET" Call="JobClassMethod"/>
<Route Url="/:namespace/GetBuffer/:processid" Method="GET" Call="GetBuffer"/>
<Route Url="/:namespace/GetResult/:processid" Method="GET" Call="GetResult"/>
<Route Url="/:namespace/GetStatus/:processid" Method="GET" Call="GetStatus"/>
<Route Url="/:namespace/:classlist" Method="GET"  Call="IncludeClassMethod"/>
<Route Url="/:namespace"            Method="GET"  Call="GetJavaScript"/>
</Routes>
}

ClassMethod GetStatus(namespace = {$zu(5)}, processid = "") As %Status
{
   
   if '$DATA(^$JOB(processid)) {
      w "Process Is Close" 
   }else {
      w "Process Is Worc"    
   }
   q 1
}

ClassMethod GetResult(namespace = {$zu(5)}, processid = "") As %Status
{
    if $d(^mtempBufferZWebDevLibjsDrawConsole(processid)){
	  if $d(^mtempBufferZWebDevLibjsDrawConsole(processid,"RESULT")){
 		  s line=^mtempBufferZWebDevLibjsDrawConsole(processid,"RESULT")
		  ; s line=$zcvt(line,"I","UTF8")
		  ; s line=$zcvt(line,"o","CP1251")
		  w line
		  k ^mtempBufferZWebDevLibjsDrawConsole(processid,"RESULT")
	  }
	  k ^mtempBufferZWebDevLibjsDrawConsole(processid)
    }
	q 1
}

ClassMethod GetBuffer(namespace = {$zu(5)}, processid = "") As %Status
{
	 if $d(^mtempBufferZWebDevLibjsDrawConsole(processid)){
	  if $d(^mtempBufferZWebDevLibjsDrawConsole(processid,"BUFF")){
	     s ind=""
	     for {
	 	    s ind=$o(^mtempBufferZWebDevLibjsDrawConsole(processid,"BUFF",ind)) 
 		    q:ind=""
	        s line=^mtempBufferZWebDevLibjsDrawConsole(processid,"BUFF",ind)
	        ; s line=$zcvt(line,"I","UTF8")
	        ; s line=$zcvt(line,"o","CP1251")
	        w line
	        k ^mtempBufferZWebDevLibjsDrawConsole(processid,"BUFF",ind) 
         } 
	   }
     }
	 q 1
}

ClassMethod IncludeClassMethod(namespace = {$zu(5)}, classlist = "") As %Status
{
   d %response.SetHeader("Content-Type","application/javascript")   
    s oldNS=$zu(5)
    d $zu(5,namespace)
    s classlist=$tr(classlist," ","")
    k filtr
	for ind=1:1:$l(classlist,","){
	   s classname=	$p(classlist,",",ind)
       s methodname=""
       if $zObjClassMethod("%CompiledClass","%ExistsId",classname)'=1 {
          s methodname=$p(classname,".",$l(classname,"."))
          s classname=$e(classname,1,$l(classname)-$l(methodname)-1)
          if $zObjClassMethod("%CompiledClass","%ExistsId",classname)'=1 {
             continue
          }
       }
       s ClassOref=##class(%ClassDefinition).%OpenId(classname)
  	   s count=ClassOref.Methods.Count()
       for i=1:1:count {
           s MethLoc=ClassOref.Methods.GetAt(i)
           if methodname'="",MethLoc.Name'=methodname  continue
           /// [ WebMethod ]
           continue:'$d(^oddDEF(MethLoc.ClassName,"m",MethLoc.Name,51))
           continue:^oddDEF(MethLoc.ClassName,"m",MethLoc.Name,51)'=1
           continue:$l(MethLoc.Language)=0
            if MethLoc.Language="javascript" {
               w !,"var "_MethLoc.Name_"=function("
               s param=MethLoc.FormalSpec
               for ind=1:1:$l(param,","){
                   s subParam=$p(param,",",ind)
                   s subParam=$p(subParam,":",1)
                   s subParam=$p(subParam,"=",1)
                   w:ind'=1 ","
                   w subParam
               }
               w "){",!
                 d ..ExecFrag(MethLoc.Code,"/*(",")*/")
                 w !,"};"
            }else{
               w !,"var "_MethLoc.Name_"=function(){",!
               s WEVENT=MethLoc.ClassName_"."_MethLoc.Name
               s WEVENT=$$$cspEncode(..GetKey(),WEVENT)
               ; s WEVENT=$$$cspDecode(%session.Key,WEVENT) 
               w "  try { var res=GetServer('"_WEVENT_"',arguments);eval(res); }catch (e) { return res}"
               w !,"};"
            }
       } 
    }
	d $zu(5,oldNS)
    q 1
}

ClassMethod GetJavaScript(namespace = {$zu(5)}) As %Status
{
   s oldNS=$zu(5)
   d $zu(5,namespace)
   d %response.SetHeader("Content-Type","application/javascript")   
    
     s ParentClassName1=##this
     s MethodName="GetServer"
     s ind=""
     w !," "_MethodName_" = function(){",!
     for {
	    s ind=$o(^oddDEF(ParentClassName1,"m",MethodName,30,ind) )
        q:ind=""
        d ..ExecFrag(^oddDEF(ParentClassName1,"m",MethodName,30,ind),"/*(",")*/")
        w !
     }
     w !," }"
     d $zu(5,oldNS)
     q 1
}

/// Метод разбики исходного текста на Cache` код и HTML текст
ClassMethod ExecFrag(SrcCode = "", Beg = "", End = "")
{
    q:SrcCode=""   q:Beg=""    q:End=""    for ExecFragInd=1:1:$l(SrcCode,End){  s tmp=$p(SrcCode,End,ExecFragInd)   s Html=$p(tmp,Beg,1)     s Code=$p(tmp,Beg,2)   w Html   TRY {     x Code    } CATCH ErrorHandle {    zw ErrorHandle  }    }
}

ClientMethod GetServer() [ Language = javascript ]
{
	  var FunCallBack=null;
      var FunProgress=null;
      var arr=new Array();
      var MethName=GetServer.arguments[0];
      if ((''+GetServer.arguments[1])=='[object Arguments]'){
         for(var ind in GetServer.arguments[1]){
	       if (GetServer.arguments[1][ind]==undefined){continue;}
           if ((FunCallBack==null)&&(typeof GetServer.arguments[1][ind] === 'function')){
	            FunCallBack=GetServer.arguments[1][ind];
	            continue;
	       }  
	       if ((FunProgress==null)&&(typeof GetServer.arguments[1][ind] === 'function')){
	            FunProgress=GetServer.arguments[1][ind];
	            continue;
	       }  
		   arr.push(GetServer.arguments[1][ind]); 
         }
      }   
      // console.log( arr );
      if (FunCallBack==null){
         var requestSendServer = new XMLHttpRequest();
         requestSendServer.open('POST', '/*(   w $zcvt(%request.URL,"O","URL")  )*//'+MethName, false);
         requestSendServer.send(JSON.stringify(arr));  
         requestSendServer.ontimeout = function (e) { alert('Time Out...');  }
         if (requestSendServer.status !== 200) {  return {"error":requestSendServer.status}  }
         return requestSendServer.responseText;
      }
     
      if (FunProgress==null){ FunProgress=function(txt){} };
      var requestSendServer = new XMLHttpRequest();
      requestSendServer.open('POST', '/*(   w $zcvt(%request.URL,"O","URL")  )*//'+MethName+'/job', false);
      requestSendServer.send(JSON.stringify(arr));  
      requestSendServer.ontimeout = function (e) { alert('Time Out...');  }
      if (requestSendServer.status !== 200) {  return {"error":requestSendServer.status}  }
      var ProcessJob=requestSendServer.responseText;
      // console.log(ProcessJob);
      var FastReportTimerId = setTimeout(function tick() {
           var requestSendServerStatus = new XMLHttpRequest();
           requestSendServerStatus.open('GET','/*(   w $zcvt(%request.URL,"O","URL")  )*//GetStatus/'+ProcessJob, false);
           requestSendServerStatus.ontimeout = function (e) { isBreck=true; alert('Error:TimeOut'); }
           requestSendServerStatus.send();  
           if (requestSendServerStatus.status !== 200) {   isBreck=true; alert('Error');  }
           // console.log(requestSendServerStatus.responseText);
           if (typeof FunProgress === 'function'){
	           var requestSendServerStatusSub = new XMLHttpRequest();
               requestSendServerStatusSub.open('GET','/*(   w $zcvt(%request.URL,"O","URL")  )*//GetBuffer/'+ProcessJob , false);
               requestSendServerStatusSub.ontimeout = function (e) {  alert('Error:TimeOut'); }
               requestSendServerStatusSub.send();  
               FunProgress(requestSendServerStatusSub.responseText); 
               // console.log(requestSendServerStatusSub.responseText);
           }
          
           if (requestSendServerStatus.responseText=="Process Is Close"){  
                clearInterval(FastReportTimerId);  
                if (typeof FunCallBack === 'function'){ 
                   var requestSendServerStatusSub = new XMLHttpRequest();
                   requestSendServerStatusSub.open('GET','/*(   w $zcvt(%request.URL,"O","URL")  )*//GetResult/'+ProcessJob , false);
                   requestSendServerStatusSub.ontimeout = function (e) {  alert('Error:TimeOut'); }
                   requestSendServerStatusSub.send();  
                   FunCallBack(requestSendServerStatusSub.responseText); 
                   //alert(requestSendServerStatusSub.responseText); 
                }
                return; 
           }
           FastReportTimerId = setTimeout(tick, /*(  if $l(..#intervalQueryStatus)>0 { w ..#intervalQueryStatus}else{ w 1000 } )*/+0 );
       }, /*(  if $l(..#intervalQueryStatus)>0 { w ..#intervalQueryStatus}else{ w 1000 } )*/+0 );
      return;
}

ClassMethod GetKey() As %String
{
	q $zu(110)
}

ClassMethod RunClassMethod(namespace = {$zu(5)}, ParentClassName As %String = {##this}) As %Status
{
   d %response.SetHeader("Content-Type","application/javascript")   
   s oldNS=$zu(5)
   d $zu(5,namespace)
   if $l(ParentClassName,".")=1 {
      s ParentClassName=$$$cspDecode(..GetKey(),ParentClassName) 
   }
   s %method=$p(ParentClassName,".",$l(ParentClassName,"."))
   s %class=$e(ParentClassName,1,$l(ParentClassName)-$l(%method)-1)
   if $zObjClassMethod("%CompiledClass","%ExistsId",%class)=1 {
       s ClassOref=##class(%ClassDefinition).%OpenId(%class)
  	   s count=ClassOref.Methods.Count()
       for i=1:1:count {
           s MethLoc=ClassOref.Methods.GetAt(i)
           continue:MethLoc.Name'=%method
           /// [ WebMethod ]
           continue:'$d(^oddDEF(MethLoc.ClassName,"m",MethLoc.Name,51))
           continue:^oddDEF(MethLoc.ClassName,"m",MethLoc.Name,51)'=1
           continue:$l(MethLoc.Language)=0
           s json=""
	       if $isobject(%request.Content){
	         for {
		       q:%request.Content.AtEnd
		       s line=%request.Content.Read(32000)	     
	           s line=$zcvt(line,"I","UTF8")
		       ; s line=$zcvt(line,"o","CP1251")
	           s json=json_line	     
	         }	
	       }
	       do ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(json,,.%override,1)
	       if $isObject(%override){
		      s numArg=0
              s ind=""
              for {
	             s ind=$o(%override.Data(ind))   
	             q:ind=""
	             s numArg=numArg+1
                 set args(numArg) =$zcvt( %override.Data(ind),"i","UTF8")
              }
              set args=numArg
           }
           if MethLoc.Language="javascript"{
              d ..ExecFrag(MethLoc.Implementation,"/*(",")*/")
           }else{
              if MethLoc.ClassMethod'=1 continue
              if $l(MethLoc.ReturnType)=0{
	            do $classmethod(%class, %method, args...)
              }else{
	            w $classmethod(%class, %method, args...)
              }
           }
       }    
   }
   d $zu(5,oldNS)
   q 1
}

ClassMethod JobClassMethod(namespace = {$zu(5)}, ParentClassName As %String = {##this}) As %Status
{
   d %response.SetHeader("Content-Type","application/javascript")   
   s oldNS=$zu(5)
   d $zu(5,namespace)
   if $l(ParentClassName,".")=1 {
      s ParentClassName=$$$cspDecode(..GetKey(),ParentClassName) 
   }
   s %method=$p(ParentClassName,".",$l(ParentClassName,"."))
   s %class=$e(ParentClassName,1,$l(ParentClassName)-$l(%method)-1)
  
   s json=""
   if $isobject(%request.Content){
      for {
        q:%request.Content.AtEnd
         s line=%request.Content.Read(32000)	     
         s line=$zcvt(line,"I","UTF8")
         ; s line=$zcvt(line,"o","CP1251")
         s json=json_line	     
      }	
   }
   do ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(json,,.%override,1)
   if '$isObject(%override){
     do ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject("[]",,.%override,1)
   }
   s gl=..#GlobalMessage_"("_$job_")"
   s @gl@("%class")=%class
   s @gl@("%method")=%method
   for ind=1:1:%override.Size {
     s @gl@(ind)=%override.GetAt(ind)
   }
   job ..ExecRunJobMethod(gl)
   w $zchild
   d $zu(5,oldNS)
   q 1
}

ClassMethod ExecRunJobMethod(gl = "")
{
	 s %class=@gl@("%class")
	 k @gl@("%class")
	 s %method=@gl@("%method")
	 k @gl@("%method")
     s numArg=0,ind=""
     for {
	    s ind=$o(@gl@(ind))
	    q:ind=""
 	    s numArg=numArg+1
        // set args(numArg) = $zcvt(override.GetAt(j),"i","UTF8")
        set args(numArg) = @gl@(ind)
        k @gl@(ind)
     }
	 s args=numArg
     d ..DrawBegin()	 
	 if '$d(^oddDEF(%class,"m",%method,70)) {
	    if $System.CLS.IsMthd(%class,%method)=1,'$d(^oddDEF(%class,"m",%method)){
		   s ^mtempBufferZWebDevLibjsDrawConsole($job,"RESULT")= $classmethod(%class, %method, args...)
		   q
	    }
	    if '$d(^oddDEF(%class,"m",%method,42)) {
	       do $classmethod(%class, %method, args...)
        } Else {
           s ^mtempBufferZWebDevLibjsDrawConsole($job,"RESULT")= $classmethod(%class, %method, args...)
        }
     }else{
        if $d(^oddDEF(%class,"m",%method,30)){
          for ind=1:1:^oddDEF(%class,"m",%method,30){
             w:ind'=1 $c(13,10)
             d ..ExecFrag(^oddDEF(%class,"m",%method,30,ind),"/*(",")*/")
          }
        }
     }
     d ..DrawEnd()
}

ClassMethod redirects() [ Internal, ProcedureBlock = 0 ]
{
wstr(s)  s ^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF")=$get(^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF"),0)  s ^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF",$i( ^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF") ))=s          q
wchr(c)  s ^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF")=$get(^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF"),0)  s ^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF",$i( ^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF") ))=$c(c)      q
wnl      s ^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF")=$get(^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF"),0)  s ^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF",$i( ^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF") ))=$$$NL      q
wff      s ^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF")=$get(^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF"),0)  s ^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF",$i( ^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF") ))=$c(12)     q
wtab(s)  s ^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF")=$get(^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF"),0)  s ^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF",$i( ^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF") ))=s          q
}

ClassMethod DrawBegin() [ ProcedureBlock = 1 ]
{
	k ^mtempBufferZWebDevLibjsDrawConsole($job,"BUFF")
	s %LastIO=$IO
    u %LastIO::("^"_$zn)
    d ##class(%Device).ReDirectIO($$$YES)
}

ClassMethod DrawEnd()
{
 	d ##class(%Device).ReDirectIO($$$NO)
    u %LastIO
}

}

