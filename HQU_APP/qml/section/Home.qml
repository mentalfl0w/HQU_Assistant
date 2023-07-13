import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import "qrc:/HQU_Assistant/qml/global/"
import "qrc:/HQU_Assistant/qml/hqu/uni_platform/component"
import "qrc:/HQU_Assistant/qml/hqu/global"
import "qrc:/HQU_Assistant/qml/fjsjyt/global"
import FluentUI 1.0

FluScrollablePage{
    id:home

    launchMode: FluPage.SingleTask

    Component.onDestruction: {
        HQUPlatformInfo.priority = -1
        FJSJYTInfo.priority = -1
    }

    Component.onCompleted: {
        hqu_connect.onNeed_update_userInfo()
        fjsjyt_connect.onNeed_update_userInfo()
    }

    ListModel{
        id:model_header
        ListElement{
            icon:"qrc:/HQU_Assistant/res/image/logo.png"
            title:"HQU助手"
            desc:"一个基于微软FluentUI设计的办公辅助软件。"
            url:"https://blog.ourdocs.cn/关于hqu助手/"
        }
        ListElement{
            icon:"qrc:/HQU_Assistant/res/image/help.png"
            title:"帮助"
            desc:"点击卡片查看帮助。"
            url:"https://blog.ourdocs.cn/hqu助手操作指南/"
        }
        ListElement{
            icon:"qrc:/HQU_Assistant/res/svg/avatar_7.svg"
            title:"作者：刘江南"
            desc:"点击卡片访问我的博客。"
            url:"https://blog.ourdocs.cn"
        }
    }

    Item{
        Layout.fillWidth: true
        height: 320
        FluRectangle{
            id: image_bar
            radius: [8,8,8,8]
            width: parent.width
            height:parent.height
            shadow: false
            FluCarousel{
                loopTime: 15000
                showIndicator: false
                anchors.fill: parent
                Component.onCompleted: {
                    setData([{url:"http://id.hqu.edu.cn/authserver/hquTheme/customStatic/web/images/bg1.jpg"},
                             {url:"http://id.hqu.edu.cn/authserver/hquTheme/customStatic/web/images/bg2.jpg"},
                             {url:"http://id.hqu.edu.cn/authserver/hquTheme/customStatic/web/images/bg3.jpg"}])
                }
            }
            Rectangle{
                anchors.fill: parent
                gradient: Gradient{
                    GradientStop { position: 0.8; color: FluTheme.dark ? Qt.rgba(0,0,0,0) : Qt.rgba(1,1,1,0) }
                    GradientStop { position: 1.0; color: FluTheme.dark ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1) }
                }
            }
        }
        FluText{
            text:"HQU助手"
            textColor: FluColors.White
            font: FluTextStyle.TitleLarge
            anchors{
                top: parent.top
                left: parent.left
                topMargin: 20
                leftMargin: 20
            }
        }
        ListView{
            id: user_list
            anchors{
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: 10
            }
            Connections
            {
                id: hqu_connect
                target: HQUPlatformInfo
                function onNeed_update_userInfo(){
                    if (HQUPlatformInfo.is_login)
                    {
                        if (HQUPlatformInfo.priority<0)
                        {
                            HQUPlatformInfo.priority = model_user.count
                            model_user.append({
                                                  name: HQUPlatformInfo.user_info_raw.name[0],
                                                  title: "华侨大学平台",
                                                  text: `欢迎您，${HQUPlatformInfo.user_info_raw.name}`,
                                                  unread: HQUPlatformInfo.unread_noti,
                                                  visible: true,
                                                  data:{
                                                      avatar_t: HQUPlatformInfo.user_info_raw.name,
                                                      info: HQUPlatformInfo.user_info
                                                  }
                                              })
                        }
                        else
                        {
                            model_user.get(HQUPlatformInfo.priority).name = HQUPlatformInfo.user_info_raw.name[0]
                            model_user.get(HQUPlatformInfo.priority).title = "华侨大学平台"
                            model_user.get(HQUPlatformInfo.priority).text = `欢迎您，${HQUPlatformInfo.user_info_raw.name}`
                            model_user.get(HQUPlatformInfo.priority).unread = HQUPlatformInfo.unread_noti
                            model_user.get(HQUPlatformInfo.priority).data = {
                                avatar_t: model_user.get(HQUPlatformInfo.priority).name,
                                info: HQUPlatformInfo.user_info
                            }
                            model_user.get(HQUPlatformInfo.priority).visible = true
                        }
                    }
                }

                function onUnread_notiChanged(){
                    model_user.get(HQUPlatformInfo.priority).unread = HQUPlatformInfo.unread_noti
                }

                function onIs_loginChanged(){
                    if (!HQUPlatformInfo.is_login)
                    {
                        model_user.remove(HQUPlatformInfo.priority)
                        HQUPlatformInfo.priority = -1
                    }
                }
            }

            Connections
            {
                id: fjsjyt_connect
                target: FJSJYTInfo
                function onNeed_update_userInfo(){
                    if (FJSJYTInfo.is_login)
                    {
                        if (FJSJYTInfo.priority<0)
                        {
                            FJSJYTInfo.priority = model_user.count
                            model_user.append({
                                                  name: FJSJYTInfo.user_info_raw.UserNameTitle[0],
                                                  title: "福建省教育厅平台",
                                                  text: `欢迎您，${FJSJYTInfo.user_info_raw.UserNameTitle}`,
                                                  unread: FJSJYTInfo.unread_noti,
                                                  visible: true,
                                                  data:{
                                                      avatar_t: FJSJYTInfo.user_info_raw.UserNameTitle,
                                                      info: FJSJYTInfo.user_info
                                                  }
                                              })
                        }
                        else
                        {
                            model_user.get(FJSJYTInfo.priority).name = FJSJYTInfo.user_info_raw.UserNameTitle[0]
                            model_user.get(FJSJYTInfo.priority).title = "福建省教育厅平台"
                            model_user.get(FJSJYTInfo.priority).text = `欢迎您，${FJSJYTInfo.user_info_raw.UserNameTitle}`
                            model_user.get(FJSJYTInfo.priority).unread = FJSJYTInfo.unread_noti
                            model_user.get(FJSJYTInfo.priority).data = {
                                avatar_t: model_user.get(FJSJYTInfo.priority).name,
                                info: FJSJYTInfo.user_info
                            }
                            model_user.get(FJSJYTInfo.priority).visible = true
                        }
                    }
                }

                function onUnread_notiChanged(){
                    model_user.get(FJSJYTInfo.priority).unread = FJSJYTInfo.unread_noti
                }

                function onIs_loginChanged(){
                    if (!FJSJYTInfo.is_login)
                    {
                        model_user.remove(FJSJYTInfo.priority)
                        FJSJYTInfo.priority = -1
                    }
                }
            }

            layoutDirection:Qt.RightToLeft
            orientation: ListView.Horizontal
            height: 120
            model:ListModel{
                id:model_user
            }

            header: Item{height: 10;width: 10}
            footer: Item{height: 10;width: 10}
            ScrollBar.horizontal: FluScrollBar{
                id: scrollbar_user
            }
            clip: false
            delegate:Item{
                id: control
                visible: model.visible
                width: user_list.height
                height: user_list.height
                FluArea{
                    radius: 8
                    width: user_list.height - 20
                    height: user_list.height - 20
                    anchors.centerIn: parent
                    color: 'transparent'
                    FluAcrylic {
                        sourceItem: image_bar
                        anchors.fill: parent
                        color: FluTheme.dark ? Window.active ?  Qt.rgba(38/255,44/255,54/255,1) : Qt.rgba(39/255,39/255,39/255,1) : Qt.rgba(251/255,251/255,253/255,1)
                        rectX: -user_list.contentX - width - 10 - (control.width)*index
                        rectY: user_list.y + 10
                        acrylicOpacity:0.7
                    }
                    Rectangle{
                        anchors.fill: parent
                        radius: 8
                        color:{
                            if(FluTheme.dark){
                                if(user_item_mouse.containsMouse){
                                    return Qt.rgba(1,1,1,0.03)
                                }
                                return Qt.rgba(0,0,0,0)
                            }else{
                                if(user_item_mouse.containsMouse){
                                    return Qt.rgba(0,0,0,0.03)
                                }
                                return Qt.rgba(0,0,0,0)
                            }
                        }
                    }
                    ColumnLayout{
                        anchors.centerIn: parent
                        spacing: 3
                        Rectangle{
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 50
                            color: 'transparent'
                            FluRectangle{
                                width: 50
                                height: 50
                                radius: [25,25,25,25]
                                color: FluTheme.dark ? Window.active ?  Qt.rgba(38/255,44/255,54/255,1) : Qt.rgba(39/255,39/255,39/255,1) : Qt.rgba(251/255,251/255,253/255,1)
                                FluText{
                                    text: model.name[0]
                                    font.pixelSize: 25
                                    anchors.centerIn: parent
                                }
                            }
                            FluBadge{
                                count: model.unread
                                visible: model.unread > 0
                                isDot: true
                                topRight: true
                                color: 'red'
                            }
                        }
                        FluText{
                            Layout.alignment: Qt.AlignHCenter
                            text: model.title
                            font.pixelSize: 11
                        }
                        FluText{
                            Layout.alignment: Qt.AlignHCenter
                            text: model.text
                            font.pixelSize: 11
                        }
                    }
                    MouseArea{
                        id:user_item_mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onWheel: (wheel)=>{
                                     if (wheel.angleDelta.y > 0) scrollbar_header.decrease()
                                     else scrollbar_header.increase()
                                 }
                        onClicked: {
                            show_popup("qrc:/HQU_Assistant/qml/component/UserInfo.qml", {argument:model.data})
                        }
                    }
                }
            }
        }
    }

    ListView{
        Layout.fillWidth: true
        orientation: ListView.Horizontal
        height: 240
        model: model_header
        header: Item{height: 10;width: 10}
        footer: Item{height: 10;width: 10}
        ScrollBar.horizontal: FluScrollBar{
            id: scrollbar_header
        }
        clip: false
        delegate:Item{
            width: 220
            height: 230
            FluArea{
                radius: 8
                width: parent.width - 20
                height: 160
                anchors.centerIn: parent
                Rectangle{
                    anchors.fill: parent
                    radius: 8
                    color:{
                        if(FluTheme.dark){
                            if(item_mouse.containsMouse){
                                return Qt.rgba(1,1,1,0.03)
                            }
                            return Qt.rgba(0,0,0,0)
                        }else{
                            if(item_mouse.containsMouse){
                                return Qt.rgba(0,0,0,0.03)
                            }
                            return Qt.rgba(0,0,0,0)
                        }
                    }
                }

                ColumnLayout{
                    FluRectangle{
                        Layout.topMargin: 20
                        Layout.leftMargin: 20
                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 50
                        radius: [25,25,25,25]
                        width: 50
                        height: 50
                        Image{
                            anchors.fill: parent
                            source: model.icon
                            fillMode:Image.PreserveAspectFit
                            height: parent.height
                            width: parent.width
                        }
                    }
                    FluText{
                        text: model.title
                        font:  FluTextStyle.Body
                        Layout.topMargin: 20
                        Layout.leftMargin: 20
                    }
                    FluText{
                        text: model.desc
                        Layout.topMargin: 5
                        Layout.preferredWidth: 160
                        Layout.leftMargin: 20
                        color: FluColors.Grey120
                        font.pixelSize: 12
                        wrapMode: Text.WrapAnywhere
                    }
                }
                FluIcon{
                    iconSource: FluentIcons.OpenInNewWindow
                    iconSize: 15
                    anchors{
                        bottom: parent.bottom
                        right: parent.right
                        rightMargin: 10
                        bottomMargin: 10
                    }
                }
                MouseArea{
                    id:item_mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onWheel: (wheel)=>{
                                 if (wheel.angleDelta.y > 0) scrollbar_header.decrease()
                                 else scrollbar_header.increase()
                             }
                    onClicked: {
                        Qt.openUrlExternally(model.url)
                    }
                }
            }
        }
    }
}
