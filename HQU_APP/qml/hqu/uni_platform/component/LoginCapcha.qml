import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import FluentUI 1.0
import FileIO 1.0

FluPopup{

    id: control
    implicitHeight:capcha_layout.implicitHeight + 20
    implicitWidth: capcha_layout.implicitWidth + 20
    signal slideOver(int length)

    FluIconButton
    {
        anchors.top: parent.top
        anchors.right: parent.right
        iconSource: FluentIcons.ChromeCloseContrast
        iconSize: 16
        onClicked: control.close()
    }
    ColumnLayout{
        id: capcha_layout
        anchors
        {
            centerIn:parent
        }
        spacing: 10

        FluText
        {
            id: title
            text: "滑动来完成验证"
            font:  FluTextStyle.Subtitle
            Layout.alignment: Qt.AlignHCenter
        }

        FluArea
        {
            Layout.alignment: Qt.AlignHCenter
            height:big_img.height +20
            width: big_img.width + 20

            Image{
                id: big_img
                width: 280
                anchors.centerIn: parent
                fillMode:Image.PreserveAspectFit
                horizontalAlignment: Image.AlignHCenter
            }
            Image{
                id: small_img
                anchors
                {
                    top: big_img.top
                }
                x:x
                sourceSize.height:  big_img.height
                fillMode:Image.PreserveAspectFit
                horizontalAlignment: Image.AlignHCenter
            }
        }
        FluArea
        {
            Layout.alignment: Qt.AlignHCenter
            width:big_img.width+20
            height: 44
            FluRectangle
            {
                id: grabber
                property int slideLen: x - parent.x - 10
                radius: [8,8,8,8]
                x: parent.x + 10
                color: FluTheme.dark ? Qt.rgba(38/255,44/255,54/255,1) : Qt.rgba(251/255,251/255,253/255,1)
                anchors
                {
                    verticalCenter: parent.verticalCenter
                    topMargin: 5
                    leftMargin: 5
                }
                height: parent.height - 10
                width: height + 10
                onXChanged: small_img.x = x
                Behavior on x {
                    NumberAnimation{
                        duration: 167
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [ 0, 0, 0, 1 ]
                    }
                }
                FluText
                {
                    text: "|||"
                    font:  FluTextStyle.Body
                    anchors.centerIn: parent
                }
                Rectangle{
                    anchors.fill: parent
                    color: {
                        if(FluTheme.dark){
                            if(grabber_mouse.containsMouse){
                                return Qt.rgba(1,1,1,0.03)
                            }
                            return Qt.rgba(0,0,0,0)
                        }else{
                            if(grabber_mouse.containsMouse){
                                return Qt.rgba(0,0,0,0.03)
                            }
                            return Qt.rgba(0,0,0,0)
                        }
                    }
                }
            }
            MouseArea
            {
                id: grabber_mouse
                anchors.fill: grabber
                drag.target: grabber
                drag.axis: Drag.XAxis
                drag.minimumX: 10
                drag.maximumX: parent.width - 10 - small_img.width
                onPressed:
                {

                }
                onReleased:
                {
                    slideOver(grabber.slideLen)
                    grabber.x = 10
                }
            }
        }
    }
    function setCapchaIMG(big_image, small_image)
    {
        big_img.source = `data:image/png;base64, ${big_image}`
        small_img.source = `data:image/png;base64, ${small_image}`
    }
}
