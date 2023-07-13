pragma Singleton

import QtQuick 2.15
import FluentUI 1.0
import QmlHttpRequest 1.0

FluObject{
    
    //通过Json对象输出url的query字符串
    function urlQuery(jsonObject) {
        var query = "";
        var i = 0;
        for(var iter in jsonObject) {
            if(i > 0) {
                query += "&";
            }
            query += iter +"=" + encodeURI(jsonObject[iter]);
            i++;
        }
        // console.log("url query:", query);
        return query;
    }
    //设置头
    function setHeader(xhr, headers) {
        //"Content-Type":"application/x-www-form-urlencoded"
        for(var iter in headers) {
            xhr.setRequestHeader(iter, headers[iter]);
        }
    }
    //这里我修改了一下函数的形参，从使用的角度来看，回调函数一般都会有，但是headers不一定要设置，所以调换了一下位置
    function ajax(method, url, callable, data, headers, progress_callback) {
        var xhr = QmlHttpRequest.newRequest();
        xhr.timeout = 200000
        headers = headers || {};
        callable = callable || function(xhr) {
            console.log("没有设置callable，使用默认log函数")
            console.log(xhr.status);
            console.log(xhr.responseText);
        }
        xhr.onreadystatechange = function() {
            if(xhr.readyState === QmlHttpRequest.Done) {
                callable(xhr);
            }
        }
        if (progress_callback)
        {
            if (method === "GET" || method === "POST")
                xhr.ondownloadprogress = function (sentBytes, totalBytes){
                    progress_callback(sentBytes, totalBytes)
                }
            else
                xhr.onuploadprogress = function (sentBytes, totalBytes){
                    progress_callback(sentBytes, totalBytes)
                }
        }

        xhr.open(method, url);
        xhr.setRequestHeader('Content-Type', 'application/json');
        setHeader(xhr, headers);
        if("GET" === method) {
            xhr.send();
        } else {
            xhr.send(data);
        }
    }

}
