import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import FluentUI
import Config
import "../global/"
import "qrc:/HQU_Assistant/qml/fjsjyt/global/"
import "qrc:/HQU_Assistant/qml/hqu/global/"
import "../component/"



CustomWindow {
    id:rootwindow
    width: 1000
    height: 640
    title: "HQU助手"
    closeDestory:false
    appBarVisible: false
    minimumWidth: 520
    minimumHeight: 460
    launchMode: FluWindow.SingleTask

    property var sys_tray: tray
    property alias navigationView: nav_view
    property alias app_Popup: window_popup
    property alias waitLoop: wait_loop

    closeFunc:function(event){
        rootwindow.show()
        rootwindow.raise()
        rootwindow.requestActivate()
        close_app.open()
        event.accepted = false
    }

    Component.onCompleted:
    {
        FJSJYTInfo.root_window = rootwindow
        HQUPlatformInfo.root_window = rootwindow
        ItemsFooter.root_window = rootwindow
        tray.showMessage("欢迎", "欢迎使用HQU助手！",SystemTrayIcon.Information)
        init_settings()
    }

    SystemTrayIcon {
        id:tray
        visible: true
        tooltip: "HQU助手"
        menu: Menu {
            MenuItem {
                text: "显示"
                icon.source: FluentIcons.DeviceLaptopNoPic
                onTriggered: {
                    rootwindow.show()
                    rootwindow.raise()
                    rootwindow.requestActivate()
                }
                shortcut: "Ctrl+S"
            }

            MenuItem {
                text: "退出"
                icon.source: FluentIcons.PowerButton
                onTriggered: {
                    rootwindow.deleteWindow()
                    FluApp.closeApp()
                }
                shortcut: "Ctrl+Z"
            }
        }
        onMessageClicked:{
            rootwindow.show()
            rootwindow.raise()
            rootwindow.requestActivate()
        }

        icon.source: "qrc:/HQU_Assistant/res/image/logo.png"

        onActivated:
            (reason)=>{
                if(reason === SystemTrayIcon.DoubleClick){
                    rootwindow.show()
                    rootwindow.raise()
                    rootwindow.requestActivate()
                }
            }
    }

    FluContentDialog{
        id:close_app
        title:"退出"
        message:"确定要退出程序吗？"
        negativeText:"最小化"
        buttonFlags: FluContentDialog.NeutralButton | FluContentDialog.NegativeButton | FluContentDialog.PositiveButton
        onNegativeClicked:{
            rootwindow.hide()
            tray.showMessage("HQU助手","已隐藏至状态栏,点击此通知或双击状态栏图标可取消隐藏。",SystemTrayIcon.Information,0);
        }
        positiveText:"退出"
        neutralText:"取消"
        onPositiveClicked:{
            rootwindow.deleteWindow()
            FluApp.closeApp()
        }
        blurSource: nav_view
    }

    FluAppBar {
        id: title_bar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        darkText: lang.dark_mode
        showDark: true
        darkClickListener:function(button){
            if(FluTheme.dark){
                FluTheme.darkMode = FluDarkMode.Light
            }else{
                FluTheme.darkMode = FluDarkMode.Dark
            }
        }
        z:7
    }

    FluNavigationView{
        id:nav_view
        anchors{
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        z:999
        pageMode: FluNavigationView.NoStack
        items: ItemsOriginal
        footerItems:ItemsFooter
        topPadding:FluTools.isMacos() ? 20 : 5
        displayMode:MainEvent.displayMode
        logo: "qrc:/HQU_Assistant/res/image/logo.png"
        title:"HQU助手"
        onLogoClicked:{
            show_popup("qrc:/HQU_Assistant/qml/component/About.qml")
        }
        autoSuggestBox:FluAutoSuggestBox{
            width: 280
            anchors.centerIn: parent
            iconSource: FluentIcons.Search
            items: ItemsOriginal.getSearchData()
            placeholderText: lang.search
            onItemClicked:
                (data)=>{
                    ItemsOriginal.startPageByItem(data)
                }
        }
        Component.onCompleted: {
            ItemsOriginal.navigationView = nav_view
            ItemsFooter.navigationView = nav_view
            setCurrentIndex(0)
        }
    }

    FluPopup
    {
        id: window_popup
        blurSource: nav_view
        onClosed: {
            FluTools.deleteItem(window_popup.contentItem)
        }
    }

    WaitingLoop
    {
        id:wait_loop
        blurSource: nav_view
    }

    function show_popup(content_url, argument)
    {
        let component = Qt.createComponent(content_url,window_popup)

        if (component.status === Component.Error) {
            console.log("Error loading component:", component.errorString());
            return
        }
        else
        {
            if (typeof(argument)!='undefined')
                window_popup.contentItem = component.createObject(undefined,argument)
            else
                window_popup.contentItem = component.createObject(undefined)
        }
        window_popup.open()
    }

    function close_popup()
    {
        window_popup.close()
    }

    function init_settings()
    {
        if (typeof(Config.get("app_settings","darkmode"))!=='undefined')
            FluTheme.darkMode = Config.get("app_settings","darkmode")
        if (typeof(Config.get("app_settings","style_color"))!=='undefined')
        {
            let colors = [FluColors.Yellow,FluColors.Orange,FluColors.Red,FluColors.Magenta,FluColors.Purple,FluColors.Blue,FluColors.Teal,FluColors.Green]
            for (let i = 0;i<colors.length;i++)
                if(colors[i].normal === Config.get("app_settings","style_color"))
                {
                    FluTheme.primaryColor = colors[i]
                    break
                }
        }
        if (typeof(Config.get("app_settings","native_text"))!=='undefined')
            FluTheme.nativeText = Config.get("app_settings","native_text")==='true'
        if (typeof(Config.get("app_settings","nav_mode"))!=='undefined')
            MainEvent.displayMode = Config.get("app_settings","nav_mode")
        if (typeof(Config.get("app_settings","language"))!=='undefined')
            appInfo.changeLang(Config.get("app_settings","language"))
    }
}
