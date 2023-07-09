﻿import QtQuick 2.12
import QtQuick.Layouts 1.12
import FluentUI 1.0
import org.wangwenx190.FramelessHelper 1.0

FluWindow {

    id:window

    property bool fixSize
    property alias titleVisible: title_bar.titleVisible
    property bool appBarVisible: true
    default property alias content: container.data

    onArgumentChanged: frameless_helper.moveWindowToDesktopCenter()

    FluAppBar {
        id: title_bar
        title: window.title
        visible: window.appBarVisible
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        darkText: lang.dark_mode
    }

    Item{
        id:container
        anchors{
            top: title_bar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        clip: true
    }

    FramelessHelper{
        id:frameless_helper
        onReady: {
            setTitleBarItem(title_bar)
            moveWindowToDesktopCenter()
            setHitTestVisible(title_bar.minimizeButton())
            setHitTestVisible(title_bar.maximizeButton())
            setHitTestVisible(title_bar.closeButton())
            setWindowFixedSize(fixSize)
            title_bar.maximizeButton.visible = !fixSize
            if (blurBehindWindowEnabled)
                window.backgroundVisible = false
            window.visible = true
            moveWindowToDesktopCenter()
        }
    }
    Connections{
        target: FluTheme
        function onDarkChanged(){
            if (FluTheme.dark)
                FramelessUtils.systemTheme = FramelessHelperConstants.Dark
            else
                FramelessUtils.systemTheme = FramelessHelperConstants.Light
        }
    }

    function setHitTestVisible(com){
        frameless_helper.setHitTestVisible(com)
    }

    function setTitleBarItem(com){
        frameless_helper.setTitleBarItem(com)
    }

}
