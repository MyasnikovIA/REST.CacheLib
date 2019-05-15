# REST.CacheLib
Библиотека для запуска класс-методов Cache' через REST API 
<br>
<br>Import lib:
<br>  d $SYSTEM.OBJ.Load("D:\tmp\REST.CacheLib.cls","c")	
<br>Export lib:
<br>  d $SYSTEM.OBJ.ExportUDL("REST.CacheLib.cls","D:\tmp\REST.CacheLib.cls")	

<h3>Подключение библиотеки в HTML :</h3>

<pre>
     <script language="JavaScript" type="text/javascript" src="http://localhost:57772/<-WebApp->/<-namespace->"></script>
     <script language="JavaScript" type="text/javascript" src="http://localhost:57772/<-WebApp->/<-namespace->/User.test"></script>
</pre>

<h3>Пример использования:</h3>
<pre>
<html>
 <head>
   <script language="JavaScript" type="text/javascript" src="http://localhost:57772/android"></script>
   <script language="JavaScript" type="text/javascript" src="http://localhost:57772/android/User.test"></script>
   <script language="JavaScript">
    callBack=function(txt){
	    alert('callBack:'+txt)
    }
 
    ProgressBack=function(txt){
	    alert('ProgressBack:'+txt)
    }
    
    test=function(){
	    run('www',callBack,ProgressBack)
    }  
  </script>
</head>
<body>
    <button onclick="console.log(GetServer('User.test.run','www'))"> run 2</button>
    <button onclick="test()"> run 2</button>
</body>
</html>
</pre>
