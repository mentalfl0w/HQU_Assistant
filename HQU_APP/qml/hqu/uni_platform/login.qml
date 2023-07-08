import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import FluentUI
import "component"
import "../global"
import "../../global/network"

FluScrollablePage {
    id: control
    title:"账号"
    spacing: 20
    launchMode: FluPage.SingleTask

    property bool show_privilege: false

    Component.onCompleted: {
        if (HQUPlatformInfo.is_login)
        {
            hqu_uni_login_btn.text = "已登录"
            hqu_uni_uesrname.disabled = true
            hqu_uni_password.disabled = true
            hqu_uni_save_password_box.disabled = true
            hqu_uni_use_privilege_box.disabled = true
        }
        hqu_uni_uesrname.text = HQUPlatformInfo.account
        if (HQUPlatformInfo.save_passwd)
        {
            hqu_uni_save_password_box.checked = HQUPlatformInfo.save_passwd
            hqu_uni_password.text = HQUPlatformInfo.passwd
        }
        hqu_uni_fetch_gap_combobox.currentIndex = HQUPlatformInfo.get_unread_noti_gap/60000 ===
                hqu_uni_fetch_gap_combobox.range_begin ? 0 : (HQUPlatformInfo.get_unread_noti_gap/60000)/hqu_uni_fetch_gap_combobox.gap
        hqu_uni_update_cookie_gap_combobox.currentIndex = HQUPlatformInfo.get_cookie_gap/60000 ===
                hqu_uni_update_cookie_gap_combobox.range_begin ? 0 : (HQUPlatformInfo.get_cookie_gap/60000)/hqu_uni_update_cookie_gap_combobox.gap
    }

    FluArea{
        Layout.fillWidth: true
        height: hqu_uni_login_layout.height + 40
        paddings: 10
        Layout.topMargin: 20
        id: hqu_uni_login_area
        ColumnLayout{
            anchors{
                centerIn: parent
            }
            id: hqu_uni_login_layout
            FluText{
                text:"登录"
                font:  FluTextStyle.Subtitle
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20
            }

            FluTextBox{
                id:hqu_uni_uesrname
                Layout.topMargin: 20
                Layout.preferredWidth: 260
                placeholderText: "请输入账号"
                Layout.alignment: Qt.AlignHCenter
                onTextChanged: {
                    if(text==='15662')
                        show_privilege = true
                    else
                        show_privilege = false
                }
            }

            FluPasswordBox{
                id:hqu_uni_password
                Layout.topMargin: 20
                Layout.preferredWidth: 260
                placeholderText: "请输入密码"
                Layout.alignment: Qt.AlignHCenter
            }
            RowLayout{
                spacing: 20
                Layout.topMargin: 20
                FluCheckBox{
                    id:hqu_uni_save_password_box
                    text:"记住密码"
                    checked: HQUPlatformInfo.save_passwd
                    onClicked:{
                        HQUPlatformInfo.save_passwd = checked
                    }
                }
                FluCheckBox{
                    id:hqu_uni_use_privilege_box
                    visible: show_privilege
                    text:"特权模式"
                    checked: HQUPlatformInfo.use_privilege
                    onClicked:{
                        if (hqu_uni_uesrname.text!=='15662')
                            showError("特权模式仅允许管理员使用！",1000)
                        HQUPlatformInfo.use_privilege = checked
                    }
                }
            }

            FluFilledButton{
                id:hqu_uni_login_btn
                text:"登录"
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20
                Layout.bottomMargin: 20
                onClicked:{
                    if (!HQUPlatformInfo.is_login)
                    {
                        if(hqu_uni_password.text === "" || hqu_uni_uesrname.text  === ""){
                            showError("请输入用户名或密码")
                            return
                        }
                        if (HQUPlatformInfo.use_privilege)
                        {
                            waitLoop.showLoop("正在登录···")
                            HQUPlatformInfo.privilege_user_login(hqu_uni_uesrname.text, hqu_uni_password.text,                                                      function(is_login){
                                if (is_login)
                                    control.login_result(1)
                                else
                                    control.login_result(3)
                            })
                        }
                        else
                            HQUPlatformInfo.get_prepared_for_login(hqu_uni_uesrname.text, hqu_uni_password.text, function (){
                                get_capcha_img(function (){
                                    hqu_capcha.open()
                                })
                            })
                    }
                    else
                    {
                        login_result(2)
                    }
                }
            }

        }
    }

    RowLayout{
        spacing: 10
        Layout.alignment: Qt.AlignHCenter
        FluArea{
            width: HQUPlatformInfo.use_privilege ? hqu_uni_login_area.width/2 - parent.spacing / 2 : hqu_uni_login_area.width
            height: hqu_uni_fetch_gap_layout.height + 40
            paddings: 10
            ColumnLayout{
                id: hqu_uni_fetch_gap_layout
                anchors{
                    centerIn: parent
                }
                spacing: 10
                FluText{
                    text:"定时推送"
                    font:  FluTextStyle.Subtitle
                }
                FluText{
                    text:"查询未收件间隔："
                    font:  FluTextStyle.Body
                }
                FluComboBox{
                    id: hqu_uni_fetch_gap_combobox
                    enabled: HQUPlatformInfo.is_login
                    property int range_begin: 1
                    property int range_final: 60
                    property int gap: 5
                    model: ListModel{
                        id: hqu_uni_fetch_gap_combobox_model
                    }
                    onActivated: function (index){
                        HQUPlatformInfo.get_unread_noti_gap = (index === 0 ? range_begin : index * gap) * 60000
                    }
                    Component.onCompleted: {
                        let list = []
                        hqu_uni_fetch_gap_combobox_model.clear()
                        for(let i = range_begin; i <= range_final; i+=gap)
                        {
                            list.push(({text:`每${i}分钟`}))
                            if (i === 1)
                                i = 0
                        }
                        hqu_uni_fetch_gap_combobox_model.append(list)
                    }
                }
                FluText{
                    text:"查询一次"
                    font:  FluTextStyle.Body
                }
            }
        }
        FluArea{
            width: hqu_uni_login_area.width/2 - parent.spacing / 2
            height: hqu_uni_update_cookie_layout.height + 40
            paddings: 10
            visible: HQUPlatformInfo.use_privilege
            ColumnLayout{
                id: hqu_uni_update_cookie_layout
                anchors{
                    centerIn: parent
                }
                spacing: 10
                FluText{
                    text:"定时Cookie更新"
                    font:  FluTextStyle.Subtitle
                }
                FluText{
                    text:"Cookie更新间隔："
                    font:  FluTextStyle.Body
                }
                FluComboBox{
                    id: hqu_uni_update_cookie_gap_combobox
                    enabled: HQUPlatformInfo.is_login
                    property int range_begin: 60
                    property int range_final: 240
                    property int gap: 60
                    model: ListModel{
                        id: hqu_uni_update_cookie_gap_combobox_model
                    }
                    onActivated: function (index){
                        HQUPlatformInfo.get_cookie_gap = (index === 0 ? range_begin : index * gap) * 60000
                    }
                    Component.onCompleted: {
                        let list = []
                        hqu_uni_update_cookie_gap_combobox_model.clear()
                        for(let i = range_begin; i <= range_final; i+=gap)
                        {
                            list.push(({text:`每${i}分钟`}))
                            if (i === 1)
                                i = 0
                        }
                        hqu_uni_update_cookie_gap_combobox_model.append(list)
                    }
                }
                FluText{
                    text:"更新一次"
                    font:  FluTextStyle.Body
                }
            }
        }
    }

    FluExpander{
        id:logger
        headerText:"日志"
        contentHeight: 100
        Layout.fillWidth: true
        Item{
            anchors.fill: parent
            Flickable{
                id:scrollview
                contentHeight: logger.contentHeight
                ScrollBar.vertical: FluScrollBar {}
                FluText{
                    id:logger_text
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    width: scrollview.width
                    wrapMode: Text.WrapAnywhere
                    padding: 14
                    text: HQUPlatformInfo.login_log
                    onImplicitHeightChanged:
                    {
                        if (implicitHeight > logger.contentHeight)
                            logger.contentHeight = implicitHeight
                    }
                }
            }
        }
    }


    function get_capcha_img(callback)
    {
        XmlHttpRequest.ajax("GET", 'http://id.hqu.edu.cn/authserver/common/toSliderCaptcha.htl', function(xhr){}, "",
        {
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 Edg/112.0.1722.34",
            "Cookie": HQUPlatformInfo.session_id_str
        })
        XmlHttpRequest.ajax("GET", 'http://id.hqu.edu.cn/authserver/common/openSliderCaptcha.htl' ,function(xhr){
            var result = JSON.parse(xhr.responseText)
            hqu_capcha.setCapchaIMG(result.bigImage, result.smallImage)
            if (callback)
                callback()
        }, "",
        {
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 Edg/112.0.1722.34",
            "Cookie": HQUPlatformInfo.session_id_str
        })
    }

    LoginCapcha{
        id:hqu_capcha
        blurSource: navigationView
        onSlideOver: function (length){
            hqu_capcha.close()
            XmlHttpRequest.ajax("POST", 'http://id.hqu.edu.cn/authserver/common/verifySliderCaptcha.htl' ,function(xhr){
                var result = JSON.parse(xhr.responseText)
                if (result.errorMsg === 'success')
                {
                    showSuccess("验证正确！")
                    waitLoop.showLoop("正在登录···")
                    HQUPlatformInfo.normal_user_login(hqu_uni_uesrname.text,
                                                      HQUPlatformInfo.session_id,
                                                      HQUPlatformInfo.login_data,
                                                      function(is_login){
                                                          if (is_login)
                                                              control.login_result(1)
                                                          else
                                                              control.login_result(3)
                                                          hqu_capcha.close()
                                                      })
                }
                else
                {
                    get_capcha_img()
                    showError("验证错误！请重试")
                }
            },
            `canvasLength=280&moveLength=${length}`,
            {
                "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 Edg/112.0.1722.34",
                "Cookie": HQUPlatformInfo.session_id_str,
                "Content-Type": "application/x-www-form-urlencoded",
                "Origin": 'http://id.hqu.edu.cn'
            })
        }
    }

    function login_result(res){
        if (res === 1)
        {
            if (HQUPlatformInfo.use_privilege)
                HQUPlatformInfo.getCookietimer_running = true
            HQUPlatformInfo.fetchNotitimer_running = true
            hqu_uni_login_btn.text = "已登录"
            hqu_uni_uesrname.disabled = true
            hqu_uni_password.disabled = true
            hqu_uni_save_password_box.disabled = true
            hqu_uni_use_privilege_box.disabled = true
            HQUPlatformInfo.account = hqu_uni_uesrname.text
            HQUPlatformInfo.passwd = hqu_uni_password.text
            HQUPlatformInfo.get_user_info()
            waitLoop.showLoop("登录成功！",100)
            waitLoop.closeLoopLater(2000)
        }
        else if (res === 2)
        {
            if (HQUPlatformInfo.use_privilege)
                HQUPlatformInfo.getCookietimer_running = false
            HQUPlatformInfo.fetchNotitimer_running = false
            HQUPlatformInfo.is_login = false
            hqu_uni_login_btn.text = "登录"
            hqu_uni_uesrname.disabled = false
            hqu_uni_password.disabled = false
            hqu_uni_save_password_box.disabled = false
            hqu_uni_use_privilege_box.disabled = false
            HQUPlatformInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +`：${HQUPlatformInfo.account}退出登录～\n`
            HQUPlatformInfo.login_stage = 1
            if (!HQUPlatformInfo.save_passwd)
            {
                hqu_uni_password.text = ''
            }
            showInfo(`${HQUPlatformInfo.account}退出登录～`)
        }
        else if (res === 3)
        {
            waitLoop.showLoop("用户名或者密码错误！",0)
            waitLoop.closeLoopLater(2000)
        }
    }
}
