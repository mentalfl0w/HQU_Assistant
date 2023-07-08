import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

Window {
    id:app
    color: "transparent"
    title: qsTr("HQU助手")
    flags: Qt.SplashScreen
    Component.onCompleted: {
        FluApp.init(app)
        FluTheme.enableAnimation = true
        FluTheme.darkMode = FluDarkMode.System
        FluApp.routes = {
            "/":"qrc:/HQU_Assistant/qml/page/MainPage.qml",
            "/task_browser":"qrc:/HQU_Assistant/qml/page/TaskBrowser.qml"
        }
        FluApp.initialRoute = "/"
        FluApp.run()
    }
}
