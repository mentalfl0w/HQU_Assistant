import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0

FluItem{

    id: control
    implicitHeight:content.implicitHeight + 50
    implicitWidth: content.implicitHeight + 50

    FluIconButton
    {
        anchors.top: parent.top
        anchors.right: parent.right
        iconSource: FluentIcons.ChromeCloseContrast
        iconSize: 16
        onClicked: close_popup()
    }

    ColumnLayout{
        id:content
        anchors
        {
            centerIn: parent
        }
        spacing: 10

        ColumnLayout{
            spacing: 14
            Layout.alignment: Qt.AlignHCenter
            Image{
                Layout.preferredWidth: height
                Layout.preferredHeight: height
                height:  name.implicitWidth + 80
                Layout.alignment: Qt.AlignHCenter
                fillMode:Image.PreserveAspectFit
                horizontalAlignment: Image.AlignHCenter
                source: "qrc:/HQU_Assistant/res/image/logo.png"
            }
            FluText{
                id: name
                text:"HQU助手"
                font:  FluTextStyle.Title
                Layout.alignment: Qt.AlignHCenter
            }
            RowLayout{
                Layout.alignment: Qt.AlignHCenter
                spacing: 5
                FluTextButton{
                    id: version_btn
                    topPadding:0
                    bottomPadding:0
                    text:"Version %1".arg(appInfo.version)
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: {
                        Qt.openUrlExternally('https://blog.ourdocs.cn/hqu助手更新日志/')
                    }
                    FluTooltip{
                        visible: parent.hovered
                        delay: 500
                        text: "点击查看更新日志（当前版本为测试版，如存在问题请与作者反馈）"
                    }
                }
                FluText{
                    text:"©️2023"
                    font:  FluTextStyle.Body
                    Layout.alignment: Qt.AlignVCenter

                }
            }
        }

        RowLayout{
            spacing: 14
            Layout.alignment: Qt.AlignHCenter
            FluText{
                text:"作者："
            }
            FluTextButton{
                id:name_mail
                topPadding:0
                bottomPadding:0
                text:"刘江南"
                Layout.alignment: Qt.AlignBottom
                onClicked: {
                    Qt.openUrlExternally('mailto: liujiangnan@hqu.edu.cn')
                }
                FluTooltip{
                    visible: parent.hovered
                    delay: 1000
                    text: "点击给我发邮件"
                }
            }
        }

        RowLayout{
            spacing: 14
            Layout.alignment: Qt.AlignHCenter
            FluText{
                text:"我的代码仓库："
            }
            FluTextButton{
                id:text_gitealink
                topPadding:0
                bottomPadding:0
                text:"https://git.ourdocs.cn"
                Layout.alignment: Qt.AlignBottom
                onClicked: {
                    Qt.openUrlExternally(text)
                }
            }
        }

        RowLayout{
            spacing: 14
            Layout.alignment: Qt.AlignHCenter
            FluText{
                text:"我的博客："
            }
            FluTextButton{
                topPadding:0
                bottomPadding:0
                text:"https://blog.ourdocs.cn"
                Layout.alignment: Qt.AlignBottom
                onClicked: {
                    Qt.openUrlExternally(text)
                }
            }
        }
    }
}
