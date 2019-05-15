# REST.CacheLib
Библиотека для запуска класс-методов Cache' через REST API 
<br>
<br>Import lib:
<br>  d $SYSTEM.OBJ.Load("D:\tmp\REST.CacheLib.cls","c")	
<br>Export lib:
<br>  d $SYSTEM.OBJ.ExportUDL("REST.CacheLib.cls","D:\tmp\REST.CacheLib.cls")	

<h3>Подключение библиотеки в HTML :</h3>

<pre>
     &lt;script language="JavaScript" type="text/javascript" src="http://localhost:57772/&lt;-WebApp->/&lt;-namespace->">&lt;/script>
     &lt;script language="JavaScript" type="text/javascript" src="http://localhost:57772/&lt;-WebApp->/&lt;-namespace->/User.test">&lt;/ script>
</pre>

<h3>Пример использования:</h3>
<pre>
&lt;html>
 &lt;head>
   &lt;script language="JavaScript" type="text/javascript" src="http://localhost:57772/android">&lt;/script>
   &lt;script language="JavaScript" type="text/javascript" src="http://localhost:57772/android/User.test">&lt;/script>
   &lt;script language="JavaScript">
    callBack=function(txt){
	    alert('callBack:'+txt)
    }
 
    ProgressBack=function(txt){
	    alert('ProgressBack:'+txt)
    }
    
    test=function(){
	    run('www',callBack,ProgressBack)
    }  
  &lt;/script>
&lt;/head>
&lt;body>
    &lt;button onclick="console.log(GetServer('User.test.run','www'))"> run 2&lt;/button>
    &lt;button onclick="test()"> run 2&lt;/button>
&lt;/body>
&lt;/html>
</pre>
Вызываемый класс:
<pre>

Class User.test Extends %RegisteredObject
{
   /// Необходимо указать   Language = cache, WebMethod  
   /// Если этой информации небудет, тогда метод не подключится!!!
   ClassMethod run(arg1 = "") As %String [ Language = cache, WebMethod ]
   {
      &js< alert('#($h)#') >
      h 5
      q "Result Text"
   }

}
</pre>


