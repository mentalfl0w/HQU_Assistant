import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import FluentUI 1.0
import "qrc:/HQU_Assistant/qml/global/"

FluScrollablePage{

    title:"设置"
    launchMode: FluPage.SingleTask

    FluArea{
        Layout.fillWidth: true
        Layout.topMargin: 20
        height: 270
        paddings: 10

        ColumnLayout{
            spacing: 10
            anchors{
                top: parent.top
                left: parent.left
            }
            FluText{
                text:lang.dark_mode
                font:  FluTextStyle.BodyStrong
                Layout.bottomMargin: 4
            }
            Repeater{
                model: [{title:"System",mode:FluDarkMode.System},{title:"Light",mode:FluDarkMode.Light},{title:"Dark",mode:FluDarkMode.Dark}]
                delegate:  FluRadioButton{
                    checked : FluTheme.darkMode === modelData.mode
                    text:modelData.title
                    clickListener:function(){
                        FluTheme.darkMode = modelData.mode
                    }
                }
            }

            ColumnLayout{
                spacing:0
                RowLayout{
                    Layout.topMargin: 10
                    Repeater{
                        model: [FluColors.Yellow,FluColors.Orange,FluColors.Red,FluColors.Magenta,FluColors.Purple,FluColors.Blue,FluColors.Teal,FluColors.Green]
                        delegate:  FluRectangle{
                            width: 42
                            height: 42
                            radius: [4,4,4,4]
                            color: mouse_item.containsMouse ? Qt.lighter(modelData.normal,1.1) : modelData.normal
                            FluIcon {
                                anchors.centerIn: parent
                                iconSource: FluentIcons.AcceptMedium
                                iconSize: 15
                                visible: modelData === FluTheme.primaryColor
                                color: FluTheme.dark ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
                            }
                            MouseArea{
                                id:mouse_item
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    FluTheme.primaryColor = modelData
                                }
                            }
                        }
                    }
                }
                FluText{
                    text:"native文本渲染"
                    Layout.topMargin: 20
                }
                FluToggleSwitch{
                    Layout.topMargin: 5
                    checked: FluTheme.nativeText
                    onClicked: {
                        FluTheme.nativeText = !FluTheme.nativeText
                    }
                }
            }
        }

    }

    FluArea{
        Layout.fillWidth: true
        Layout.topMargin: 20
        height: 188
        paddings: 10

        ColumnLayout{
            spacing: 10
            anchors{
                top: parent.top
                left: parent.left
            }

            FluText{
                text:lang.navigation_view_display_mode
                font:  FluTextStyle.BodyStrong
                Layout.bottomMargin: 4
            }

            Repeater{
                id:repeater
                model: [{title:"Open",mode:FluNavigationView.Open},{title:"Compact",mode:FluNavigationView.Compact},{title:"Minimal",mode:FluNavigationView.Minimal},{title:"Auto",mode:FluNavigationView.Auto}]
                delegate:  FluRadioButton{
                    checked: MainEvent.displayMode===modelData.mode
                    text:modelData.title
                    clickListener:function(){
                        MainEvent.displayMode = modelData.mode
                    }
                }
            }
        }

    }

    FluArea{
        Layout.fillWidth: true
        Layout.topMargin: 20
        height: 80
        paddings: 10

        ColumnLayout{
            spacing: 10
            anchors{
                top: parent.top
                left: parent.left
            }

            FluText{
                text:lang.locale
                font:  FluTextStyle.BodyStrong
                Layout.bottomMargin: 4
            }

            Flow{
                spacing: 5
                Repeater{
                    model: ["Zh","En"]
                    delegate:  FluRadioButton{
                        checked: appInfo.lang.objectName === modelData
                        text:modelData
                        clickListener:function(){
                            console.debug(modelData)
                            appInfo.changeLang(modelData)
                        }
                    }
                }
            }
        }

    }

}
