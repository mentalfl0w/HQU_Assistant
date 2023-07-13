import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import "qrc:/HQU_Assistant/qml/component"

CustomWindow {

    id:window

    fixSize: true

    property alias fileMng: file_mng
    property alias waitLoop: wait_loop

    width: 600
    height: 500

    launchMode: FluWindow.SingleTask

    title:"文件浏览器"
    onArgumentChanged:
    {
        //console.log(JSON.stringify(argument))
        if (argument.page_url)
        {
            load_tab(argument.title, argument.page_url, argument.argument)
        }
    }

    FluTabView{
        id:tab_view
        Layout.fillWidth: true
        addButtonVisibility: false
        closeButtonVisibility: FluTabView.OnHover
    }

    FileManager
    {
        id: file_mng
    }

    function load_tab(title, page_url, argument){
        tab_view.appendTab(
                    'qrc:/HQU_Assistant/res/image/logo.png',
                    title,
                    Qt.createComponent(page_url, tab_view),
                    argument)
    }

    WaitingLoop
    {
        id:wait_loop
        blurSource: tab_view
        blurRectY: y - 30
    }

    FluPopup
    {
        id: window_popup
        blurSource: tab_view
        blurRectY: y - 30
        onClosed: {
            window_popup.contentItem.destroy()
        }
    }

    function show_popup(content_url, arguments)
    {
        if (arguments)
            window_popup.contentItem = Qt.createComponent(content_url,window_popup).createObject(window_popup,arguments)
        else
            window_popup.contentItem = Qt.createComponent(content_url,window_popup).createObject(window_popup)
        window_popup.open()
    }

    function close_popup()
    {
        window_popup.close()
    }
}
