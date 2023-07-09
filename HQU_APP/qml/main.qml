import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import FluentUI 1.0

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
