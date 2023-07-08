import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import FluentUI
import "../global/network"
import "global"

FluScrollablePage {

    id:fjsjyt_login_page
    title:"账号"
    launchMode: FluPage.SingleTask

    Component.onCompleted: {
        if (FJSJYTInfo.is_login)
        {
            fjsjyt_login_btn.text = "已登录"
            fjsjyt_uesrname.disabled = true
            fjsjyt_password.disabled = true
            fjsjyt_save_password_box.disabled = true
        }
        fjsjyt_uesrname.text = FJSJYTInfo.account
        if (FJSJYTInfo.save_passwd)
        {
            fjsjyt_save_password_box.checked = FJSJYTInfo.save_passwd
            fjsjyt_password.text = FJSJYTInfo.passwd
        }
        fjsjyt_fetch_gap_combobox.currentIndex = FJSJYTInfo.get_unread_noti_gap/60000 ===
                fjsjyt_fetch_gap_combobox.range_begin ? 0 : (FJSJYTInfo.get_unread_noti_gap/60000)/fjsjyt_fetch_gap_combobox.gap
        fjsjyt_update_cookie_gap_combobox.currentIndex = FJSJYTInfo.get_cookie_gap/60000 ===
                fjsjyt_update_cookie_gap_combobox.range_begin ? 0 : (FJSJYTInfo.get_cookie_gap/60000)/fjsjyt_update_cookie_gap_combobox.gap
    }

    FluArea{
        Layout.fillWidth: true
        height: fjsjyt_login_layout.height + 40
        paddings: 10
        Layout.topMargin: 20
        ColumnLayout{
            anchors{
                centerIn: parent
            }
            id: fjsjyt_login_layout
            FluText{
                text:"登录"
                font:  FluTextStyle.Subtitle
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20
            }

            FluTextBox{
                id:fjsjyt_uesrname
                Layout.topMargin: 20
                Layout.preferredWidth: 260
                placeholderText: "请输入账号"
                Layout.alignment: Qt.AlignHCenter
            }

            FluPasswordBox{
                id:fjsjyt_password
                Layout.topMargin: 20
                Layout.preferredWidth: 260
                placeholderText: "请输入密码"
                Layout.alignment: Qt.AlignHCenter
            }
            FluCheckBox{
                id:fjsjyt_save_password_box
                Layout.topMargin: 20
                text:"记住密码"
                onClicked:{
                    FJSJYTInfo.save_passwd = checked
                }
            }
            FluFilledButton{
                id:fjsjyt_login_btn
                text:"登录"
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20
                Layout.bottomMargin: 20
                onClicked:{
                    if (!FJSJYTInfo.is_login)
                    {
                        if(fjsjyt_password.text === "" || fjsjyt_uesrname.text  === ""){
                            showError("请输入用户名或密码")
                            return
                        }
                        waitLoop.showLoop("正在登录···")
                        FJSJYTInfo.user_login(fjsjyt_uesrname.text, fjsjyt_password.text, function (result){
                            if (result)
                                login_result(1)
                            else
                                login_result(3)
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
        Layout.topMargin: 20
        Layout.bottomMargin: 20
        FluArea{
            Layout.fillWidth: true
            height: fjsjyt_fetch_gap_layout.height + 40
            paddings: 10
            ColumnLayout{
                id: fjsjyt_fetch_gap_layout
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
                    id: fjsjyt_fetch_gap_combobox
                    enabled: FJSJYTInfo.is_login
                    property int range_begin: 1
                    property int range_final: 60
                    property int gap: 5
                    model: ListModel{
                        id: fjsjyt_fetch_gap_combobox_model
                    }
                    onActivated: function (index){
                        FJSJYTInfo.get_unread_noti_gap = (index === 0 ? range_begin : index * gap) * 60000
                    }
                    Component.onCompleted: {
                        let list = []
                        fjsjyt_fetch_gap_combobox_model.clear()
                        for(let i = range_begin; i <= range_final; i+=gap)
                        {
                            list.push(({text:`每${i}分钟`}))
                            if (i === 1)
                                i = 0
                        }
                        fjsjyt_fetch_gap_combobox_model.append(list)
                    }
                }
                FluText{
                    text:"查询一次"
                    font:  FluTextStyle.Body
                }
            }
        }
        FluArea{
            Layout.fillWidth: true
            height: fjsjyt_update_cookie_layout.height + 40
            paddings: 10
            ColumnLayout{
                anchors{
                    centerIn: parent
                }
                id: fjsjyt_update_cookie_layout
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
                    id: fjsjyt_update_cookie_gap_combobox
                    enabled: FJSJYTInfo.is_login
                    property int range_begin: 1
                    property int range_final: 15
                    property int gap: 5
                    model: ListModel{
                        id: fjsjyt_update_cookie_gap_combobox_model
                    }
                    onActivated: function (index){
                        FJSJYTInfo.get_cookie_gap = (index === 0 ? range_begin : index * gap) * 60000
                    }
                    Component.onCompleted: {
                        let list = []
                        fjsjyt_update_cookie_gap_combobox_model.clear()
                        for(let i = range_begin; i <= range_final; i+=gap)
                        {
                            list.push(({text:`每${i}分钟`}))
                            if (i === 1)
                                i = 0
                        }
                        fjsjyt_update_cookie_gap_combobox_model.append(list)
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
                    id:fjsjyt_login_loading_text
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    width: scrollview.width
                    wrapMode: Text.WrapAnywhere
                    padding: 14
                    text: FJSJYTInfo.login_log
                    onImplicitHeightChanged:
                    {
                        if (implicitHeight > logger.contentHeight)
                            logger.contentHeight = implicitHeight
                    }
                }
            }
        }
    }

    function login_result(res){
        if (res === 1)
        {
            FJSJYTInfo.getCookietimer_running = true
            FJSJYTInfo.fetchNotitimer_running = true
            fjsjyt_login_btn.text = "已登录"
            fjsjyt_uesrname.disabled = true
            fjsjyt_password.disabled = true
            fjsjyt_save_password_box.disabled = true
            FJSJYTInfo.account = fjsjyt_uesrname.text
            FJSJYTInfo.passwd = fjsjyt_password.text
            FJSJYTInfo.get_user_info()
            waitLoop.showLoop("登录成功！",100)
            waitLoop.closeLoopLater(2000)
        }
        else if (res === 2)
        {
            FJSJYTInfo.getCookietimer_running = false
            FJSJYTInfo.fetchNotitimer_running = false
            FJSJYTInfo.is_login = false
            fjsjyt_login_btn.text = "登录"
            fjsjyt_uesrname.disabled = false
            fjsjyt_password.disabled = false
            fjsjyt_save_password_box.disabled = false
            FJSJYTInfo.login_log += Qt.formatDateTime(new Date(),"yyyy-MM-dd HH:mm:ss.zzz") +"：退出登录～\n"
            if (!FJSJYTInfo.save_passwd)
            {
                fjsjyt_password.text = ''
            }
            showInfo("退出登录～")
        }
        else if (res === 3)
        {
            waitLoop.showLoop("用户名或者密码错误！",0)
            waitLoop.closeLoopLater(2000)
        }
    }
}
