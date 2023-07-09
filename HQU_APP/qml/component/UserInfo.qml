import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import FluentUI 1.0

FluItem {
    id: control
    implicitHeight: user_list.contentHeight + 50
    implicitWidth: 250
    property var argument

    FluIconButton
    {
        id: close_btn
        anchors.top: parent.top
        anchors.right: parent.right
        iconSource: FluentIcons.ChromeCloseContrast
        iconSize: 16
        onClicked: close_popup()
    }

    ListView{
        id: user_list
        width: 200
        height: 300
        anchors.top: close_btn.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        orientation: ListView.Vertical
        verticalLayoutDirection: ListView.TopToBottom

        Component.onCompleted: {
            update_info(argument.avatar_t, argument.info)
        }

        ScrollBar.vertical: FluScrollBar{
            id: scrollbar
        }
        clip: false
        header:
            Item{
            property alias text: avatar_text.text
            width: user_list.width
            height: avatar.height + 20
            FluRectangle{
                id: avatar
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 20
                width: 80
                height: 80
                color: FluTheme.dark ? Window.active ?  Qt.rgba(38/255,44/255,54/255,1) : Qt.rgba(39/255,39/255,39/255,1) : Qt.rgba(251/255,251/255,253/255,1)
                radius: [8,8,8,8]
                FluText{
                    id: avatar_text
                    font.pixelSize: 40
                    anchors.centerIn: parent
                }
            }
        }
        model:ListModel{
            id:model_data
        }
        delegate:Item{
            width: user_list.width
            height: layout.implicitHeight+10
            RowLayout{
                id:layout
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5
                FluText{
                    text:model.tag
                    font:  FluTextStyle.BodyStrong
                    Layout.alignment: Qt.AlignHCenter
                }
                FluText{
                    text:model.text
                    font:  FluTextStyle.Body
                    Layout.alignment: Qt.AlignBottom
                }
            }
        }
    }

    function update_info(avatar_t,info)
    {
        user_list.headerItem.text = avatar_t[0]
        model_data.clear()
        model_data.append(info)
    }
}
