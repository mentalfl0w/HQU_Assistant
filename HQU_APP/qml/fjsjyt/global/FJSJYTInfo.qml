pragma Singleton

import QtQuick
import QtQuick.Controls
import Qt.labs.platform
import FluentUI
import "../../global/network"

FluObject {
    property string account: ""
    property string passwd: ""
    property var token
    property string cookie: ''
    property string login_log: ""
    property bool is_login: false
    property bool save_passwd: false
    property bool is_readed: false
    property var root_window
    property int priority: -1
    property int unread_noti
    property int get_cookie_gap: 10 * 60000
    property int get_unread_noti_gap: 15 * 60000
    property string server_addr: 'hqua.ourdocs.cn'
    property string server_port: '443'
    property string server_protocol: 'https'
    property string server_url: server_protocol + '://'+server_addr+':'+server_port

    property bool getCookietimer_running: false
    property bool fetchNotitimer_running: false

    property var user_info: []
    property var user_info_raw

    signal need_update_userInfo(var userInfo)

    onGetCookietimer_runningChanged:
    {
        if (getCookietimer_running && !fjsjyt_getCookietimer.running)
        fjsjyt_getCookietimer.start()
        else
        fjsjyt_getCookietimer.stop()
    }

    onFetchNotitimer_runningChanged:
    {
        if (fetchNotitimer_running && !fjsjyt_fetchNotitimer.running)
        fjsjyt_fetchNotitimer.start()
        else
        fjsjyt_fetchNotitimer.stop()
    }

    onGet_cookie_gapChanged:
    {
        fjsjyt_getCookietimer.interval = get_cookie_gap
    }

    onGet_unread_noti_gapChanged:
    {
        fjsjyt_fetchNotitimer.interval = get_unread_noti_gap
    }

    signal need_getcookie()
    signal need_fetch_noti()

    Timer{
        id:fjsjyt_getCookietimer;
        interval: get_cookie_gap //定时周期
        repeat:true;    //
        triggeredOnStart: false;
        onTriggered:
        {
            get_cookie()
            need_getcookie()
        }
    }

    Timer{
        id:fjsjyt_fetchNotitimer;
        interval: get_unread_noti_gap //定时周期
        repeat:true;    //
        triggeredOnStart: true;
        onTriggered:
        {
            need_fetch_noti()
            get_unread_files_num(function(result){
                if (result>0)
                {
                    root_window.sys_tray.showMessage("福建省教育厅平台", `您还有${FJSJYTInfo.unread_noti}条待办文件，请尽快签收办理！`,SystemTrayIcon.Information, 0)
                    root_window.showInfo(`福建省教育厅平台：您还有${FJSJYTInfo.unread_noti}条待办文件，请尽快签收办理！`, 5000)
                    FJSJYTInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +'：'+`${FJSJYTInfo.unread_noti}条未读消息。\n`
                }
            })
        }
    }

    function user_login(username,password,callback)
    {
        XmlHttpRequest.ajax("POST",`${FJSJYTInfo.server_url}/fjsjyt/login`,function(xhr){
            var result = JSON.parse(xhr.responseText)
            if(result.login_status===1) {
                FJSJYTInfo.token = result.token
                FJSJYTInfo.cookie = ''
                for (const [key, value] of Object.entries(result.token)) {
                    FJSJYTInfo.cookie += `${key}=${value};`
                }
                FJSJYTInfo.is_login = true
                FJSJYTInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +"：登录成功！\n"
            }else{
                FJSJYTInfo.is_login = false
                FJSJYTInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +"：用户名或者密码错误！\n"
            }
            callback(FJSJYTInfo.is_login)
        },JSON.stringify({username:username,password:password}))
    }

    function get_cookie()
    {
        user_login(FJSJYTInfo.account, FJSJYTInfo.passwd, function(result){
            if(result)
            {
                FJSJYTInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +'：'+FJSJYTInfo.account+"的Cookie已更新！\n"
                return true
            }
            else
            {
                FJSJYTInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +'：'+FJSJYTInfo.account+"的Cookie更新失败，等待下次更新！\n"
                return false
            }
        })
    }

    function get_unread_files_num(callback)
    {
        XmlHttpRequest.ajax("POST",`${FJSJYTInfo.server_url}/fjsjyt/file_count/unread`,function(xhr){
            //console.log(xhr.status);
            //console.log(xhr.responseText);
            var result = JSON.parse(xhr.responseText)
            if(result.count>=0) {
                FJSJYTInfo.unread_noti = result.count
                callback(FJSJYTInfo.unread_noti)
            }else{
                showError("获取数据失败，请检查网络！")
                callback(0)
            }
        },JSON.stringify({username:FJSJYTInfo.account,token:FJSJYTInfo.token}))
    }

    function get_user_info()
    {
        XmlHttpRequest.ajax("POST",`${FJSJYTInfo.server_url}/fjsjyt/user_info`,function(xhr){
            //console.log(xhr.status);
            //console.log(xhr.responseText);
            var result = JSON.parse(xhr.responseText)
            if(result.user_info_status) {
                FJSJYTInfo.user_info_raw = result.user_info
                FJSJYTInfo.user_info = []
                FJSJYTInfo.user_info.push({tag:'ID：', text:FJSJYTInfo.account})
                FJSJYTInfo.user_info.push({tag:'单位名称：', text:result.user_info.UserNameTitle})
                FJSJYTInfo.user_info.push({tag:'用户代号：', text:result.user_info.UserName})
                FJSJYTInfo.user_info.push({tag:'部门：', text:result.user_info.Unit})
                FJSJYTInfo.user_info.push({tag:'部门ID：', text:result.user_info.UnitID})
                need_update_userInfo(FJSJYTInfo.user_info)
                FJSJYTInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +'：'+"获取用户信息成功！\n"
            }else{
                FJSJYTInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +'：'+"获取数据失败，请检查网络！\n"
            }
        },JSON.stringify({username:FJSJYTInfo.account,token:FJSJYTInfo.token}))
    }

}

