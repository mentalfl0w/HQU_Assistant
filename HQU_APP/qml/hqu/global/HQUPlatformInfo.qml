pragma Singleton

import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.0
import FluentUI 1.0
import "../../global/network"

FluObject {
    property string account: ""
    property string passwd: ""
    property var token
    property var session_id
    property string session_id_str: ''
    property var login_data
    property int login_stage: 1
    property string cookie: ''
    property string login_log: ""
    property bool is_login: false
    property bool save_passwd: false
    property bool is_readed: false
    property bool use_privilege: false
    property var root_window
    property int priority: -1
    property int unread_noti
    property int undo_task_num: 0
    property int get_cookie_gap: 60 * 60000
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

    onUndo_task_numChanged: {
        if (undo_task_num > 0)
        {
            root_window.sys_tray.showMessage("华侨大学OA平台", `您的待办事宜发生变化，当前为${HQUPlatformInfo.undo_task_num}条。`,SystemTrayIcon.Information, 0)
            root_window.showInfo(`华侨大学OA平台：您的待办事宜发生变化，当前为${HQUPlatformInfo.undo_task_num}条。`, 5000)
            HQUPlatformInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +'：'+`${HQUPlatformInfo.undo_task_num}条待办事宜。\n`
        }
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
            get_undistributed_num(function(result){
                if (result>0)
                {
                    root_window.sys_tray.showMessage("华侨大学OA平台", `您还有${HQUPlatformInfo.unread_noti}条分发提醒，请及时处理！`,SystemTrayIcon.Information, 0)
                    root_window.showInfo(`华侨大学OA平台：您还有${HQUPlatformInfo.unread_noti}条分发提醒，请及时处理！`, 5000)
                    HQUPlatformInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +'：'+`${HQUPlatformInfo.unread_noti}条分发提醒。\n`
                }
            })
            get_undo_task_num(function(result){
            })
        }
    }

    function get_prepared_for_login(username,password, callback)
    {
        HQUPlatformInfo.login_stage = 1
        XmlHttpRequest.ajax("POST",`${HQUPlatformInfo.server_url}/hqu/uni/login`,function(xhr){
            var result = JSON.parse(xhr.responseText)
            if(result.login_status===0 && result.stage===2) {
                HQUPlatformInfo.login_data = result.login_data
                HQUPlatformInfo.session_id_str = ''
                HQUPlatformInfo.session_id = result.session_id
                HQUPlatformInfo.login_stage = result.stage
                for (const [key, value] of Object.entries(result.session_id)) {
                    HQUPlatformInfo.session_id_str += `${key}=${value}; `
                }

                HQUPlatformInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +`：${username}登录成功！\n`
            }else{
                HQUPlatformInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +"：当前服务暂不可用！\n"
            }
            callback(HQUPlatformInfo.session_id, HQUPlatformInfo.login_data)
        },JSON.stringify({
                             username:username,
                             password:password,
                             stage: HQUPlatformInfo.login_stage,
                             session_id:'',
                             login_data:''
                         }))
    }

    function normal_user_login(username, session_id, login_data, callback)
    {
        XmlHttpRequest.ajax("POST",`${HQUPlatformInfo.server_url}/hqu/uni/login`,function(xhr){
            var result = JSON.parse(xhr.responseText)
            if(result.login_status===1) {
                HQUPlatformInfo.token = result.token
                HQUPlatformInfo.cookie = ''
                for (const [key, value] of Object.entries(result.token)) {
                    HQUPlatformInfo.cookie += `${key}=${value}; `
                }
                HQUPlatformInfo.is_login = true
                HQUPlatformInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +`：${username}登录成功！\n`
            }else{
                HQUPlatformInfo.is_login = false
                HQUPlatformInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +"：用户名或者密码错误！\n"
            }
            callback(HQUPlatformInfo.is_login)
        },JSON.stringify({
                             username:username,
                             password:'',
                             stage: HQUPlatformInfo.login_stage,
                             session_id:HQUPlatformInfo.session_id,
                             login_data:HQUPlatformInfo.login_data
                         }))
    }

    function privilege_user_login(username, password, callback)
    {
        HQUPlatformInfo.login_stage = 0
        XmlHttpRequest.ajax("POST",`${HQUPlatformInfo.server_url}/hqu/uni/login`,function(xhr){
            var result = JSON.parse(xhr.responseText)
            if(result.login_status===1) {
                HQUPlatformInfo.token = result.token
                HQUPlatformInfo.cookie = ''
                for (const [key, value] of Object.entries(result.token)) {
                    HQUPlatformInfo.cookie += `${key}=${value}; `
                }
                HQUPlatformInfo.is_login = true
                HQUPlatformInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +`：${username}登录成功！\n`
            }else{
                HQUPlatformInfo.is_login = false
                HQUPlatformInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +"：用户名或者密码错误！\n"
            }
            callback(HQUPlatformInfo.is_login)
        },JSON.stringify({
                             username:username,
                             password:password,
                             stage: HQUPlatformInfo.login_stage,
                             session_id:'',
                             login_data:''
                         }))
    }

    function get_cookie()
    {
        privilege_user_login(HQUPlatformInfo.account, HQUPlatformInfo.passwd, function(result){
            if(result)
            {
                HQUPlatformInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +'：'+HQUPlatformInfo.account+"的Cookie已更新！\n"
                return true
            }
            else
            {
                HQUPlatformInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +'：'+HQUPlatformInfo.account+"的Cookie更新失败，等待下次更新！\n"
                return false
            }
        })
    }

    function get_undistributed_num(callback)
    {
        XmlHttpRequest.ajax("POST",`${HQUPlatformInfo.server_url}/hqu/oa/undistributed_note_num`,function(xhr){
            //console.log(xhr.status);
            //console.log(xhr.responseText);
            var result = JSON.parse(xhr.responseText)
            if(result.oa_status) {
                HQUPlatformInfo.unread_noti = result.num
                callback(HQUPlatformInfo.unread_noti)
            }else{
                HQUPlatformInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +'：'+"获取数据失败，请检查网络！\n"
                callback(result.oa_status)
            }
        },JSON.stringify({username:HQUPlatformInfo.account,token:HQUPlatformInfo.token}))
    }

    function get_undo_task_num(callback)
    {
        XmlHttpRequest.ajax("POST",`${HQUPlatformInfo.server_url}/hqu/oa/undo_task_num`,function(xhr){
            //console.log(xhr.status);
            //console.log(xhr.responseText);
            var result = JSON.parse(xhr.responseText)
            if(result.oa_status) {
                HQUPlatformInfo.undo_task_num = result.num
                callback(HQUPlatformInfo.undo_task_num)
            }else{
                HQUPlatformInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +'：'+"获取数据失败，请检查网络！\n"
                callback(result.oa_status)
            }
        },JSON.stringify({username:HQUPlatformInfo.account,token:HQUPlatformInfo.token}))
    }

    function get_user_info()
    {
        XmlHttpRequest.ajax("POST",`${HQUPlatformInfo.server_url}/hqu/uni/user_basic_info`,function(xhr){
            //console.log(xhr.status);
            //console.log(xhr.responseText);
            var result = JSON.parse(xhr.responseText)
            if(result.user_basic_info_status) {
                HQUPlatformInfo.user_info_raw = result.user_basic_info
                HQUPlatformInfo.user_info = []
                HQUPlatformInfo.user_info.push({tag:'ID：', text:result.user_basic_info.id})
                HQUPlatformInfo.user_info.push({tag:'姓名：', text:result.user_basic_info.name})
                HQUPlatformInfo.user_info.push({tag:'邮箱：', text:result.user_basic_info.mail})
                HQUPlatformInfo.user_info.push({tag:'电话：', text:result.user_basic_info.telephone})
                need_update_userInfo(HQUPlatformInfo.user_info)
                HQUPlatformInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +'：'+"获取用户基本信息成功！\n"
            }else{
                HQUPlatformInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +'：'+"获取数据失败，请检查网络！\n"
            }
        },JSON.stringify({username:HQUPlatformInfo.account,token:HQUPlatformInfo.token}))
    }

}

