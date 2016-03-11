

function showHint(str)
{
    var xmlhttp;
    if (str.length==0)
    {
        document.getElementById("txtHint").innerHTML="";
        return;
    }
    if (window.XMLHttpRequest)
    {// code for IE7+, Firefox, Chrome, Opera, Safari
        xmlhttp=new XMLHttpRequest();
    }
    else
    {// code for IE6, IE5
        xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
    }
    xmlhttp.onreadystatechange = function()//请求状态改变
    {
        if (xmlhttp.readyState ==4 && xmlhttp.status==200)//就绪状态
        {
            document.getElementById("filess").innerHTML = xmlhttp.responseText;
            //匹配一个 <script> </script> 标签，找出js代码
            response = xmlhttp.responseText.replace(/ <script> (.*) <\/script> /gi, "$1 ");
            //alert(response);
            //执行 
            eval(response);
        }
    }
    //document.getElementById("filess").innerHTML = "123";
    xmlhttp.open("GET","/ajax/list.html?q="+str,true);//请求初始化
    xmlhttp.send();//发送请求
}
function deleteF(str) {
    alert(str);
}

function deleteFile(str) {
    var xmlhttp;
    if (str.length==0)
    {
        document.getElementById("txtHint").innerHTML="";
        return;
    }
    if (window.XMLHttpRequest)
    {// code for IE7+, Firefox, Chrome, Opera, Safari
        xmlhttp=new XMLHttpRequest();
    }
    else
    {// code for IE6, IE5
        xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
    }
    xmlhttp.onreadystatechange=function()
    {
        if (xmlhttp.readyState==4 && xmlhttp.status==200)
        {
            document.getElementById("filess").innerHTML=xmlhttp.responseText;
            //匹配一个 <script> </script> 标签，找出js代码
            response = xmlhttp.responseText.replace(/ <script> (.*) <\/script> /gi, "$1 ");
            //alert(response);
            //执行
            eval(response);
        }
    }
    xmlhttp.open("DELETE","/ajax/list.html?q="+str,true);
    xmlhttp.send();
    
}
