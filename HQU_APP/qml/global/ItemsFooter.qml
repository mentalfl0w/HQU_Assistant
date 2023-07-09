pragma Singleton

import QtQuick 2.12
import FluentUI 1.0
import 'qrc:/HQU_Assistant/qml/component'

FluObject{
    id:footer_items

    property var navigationView
    property var root_window


    FluPaneItemSeparator{}
    FluPaneItem{
        title:lang.about
        icon:FluentIcons.Info
        tapFunc:function() {
            root_window.show_popup("qrc:/HQU_Assistant/qml/component/About.qml")
        }

    }
    FluPaneItem{
        title:lang.settings
        icon:FluentIcons.Settings
        onTap:{
            navigationView.push("qrc:/HQU_Assistant/qml/section/Settings.qml")
        }
    }
}
