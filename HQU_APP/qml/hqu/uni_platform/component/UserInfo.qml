import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import FluentUI
import "../../global"

FluItem {
    id: control
    implicitHeight: Math.max(content.implicitHeight + 50,content.implicitWidth + 50)
    implicitWidth: Math.max(content.implicitHeight + 50,content.implicitWidth + 50)

    Component.onCompleted: {
        if (HQUPlatformInfo.is_login)
        {
            update_info(HQUPlatformInfo.user_info)
        }
    }

    Connections
    {
        target: HQUPlatformInfo
        function onUser_infoChanged()
        {
            update_info(HQUPlatformInfo.user_info)
        }
    }

    FluIconButton
    {
        anchors.top: parent.top
        anchors.right: parent.right
        iconSource: FluentIcons.ChromeCloseContrast
        iconSize: 16
        onClicked: close_popup()
    }

    ColumnLayout{
        id: content
        anchors
        {
            top: parent.top
            topMargin: 20
            left: parent.left
            right: parent.right
            bottomMargin: 20
        }
        spacing: 20

        FluRectangle{
            Layout.alignment: Qt.AlignHCenter
            width: 80
            height: 80
            radius: [8,8,8,8]
            Image{
                anchors.fill: parent
                source: "qrc:/HQU_Assistant/res/svg/avatar_8.svg"
                height: parent.height
                width: parent.width
                fillMode:Image.PreserveAspectFit
            }

        }
        RowLayout{
            Layout.alignment: Qt.AlignHCenter
            FluText{
                text:"欢迎，"
                font:  FluTextStyle.BodyStrong
                Layout.alignment: Qt.AlignHCenter
            }
            FluText{
                id: name
                text:"请登录"
                font:  FluTextStyle.Body
                Layout.alignment: Qt.AlignBottom
            }
        }
        RowLayout{
            Layout.alignment: Qt.AlignHCenter
            visible: HQUPlatformInfo.is_login
            FluText{
                text:"ID："
                font:  FluTextStyle.BodyStrong
                Layout.alignment: Qt.AlignHCenter
            }
            FluText{
                id: user_id
                text:"11111"
                font:  FluTextStyle.Body
                Layout.alignment: Qt.AlignBottom
            }
        }
        RowLayout{
            Layout.alignment: Qt.AlignHCenter
            visible: HQUPlatformInfo.is_login
            FluText{
                text:"邮箱："
                font:  FluTextStyle.BodyStrong
                Layout.alignment: Qt.AlignHCenter
            }
            FluText{
                id: mail
                text:"1231@12.com"
                font:  FluTextStyle.Body
                Layout.alignment: Qt.AlignBottom
            }
        }
        RowLayout{
            Layout.alignment: Qt.AlignHCenter
            visible: HQUPlatformInfo.is_login
            FluText{
                text:"电话："
                font:  FluTextStyle.BodyStrong
                Layout.alignment: Qt.AlignHCenter
            }
            FluText{
                id: telephone
                text:"11111111111"
                font:  FluTextStyle.Body
                Layout.alignment: Qt.AlignBottom
            }
        }
    }

    function update_info(user_data)
    {
        name.text = user_data.name
        user_id.text = user_data.id
        mail.text = user_data.mail
        telephone.text = user_data.telephone
    }
}
