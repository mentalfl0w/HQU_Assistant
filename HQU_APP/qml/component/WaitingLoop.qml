import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluPopup {

    id: control
    implicitHeight:content.implicitHeight + 50
    implicitWidth: content.implicitWidth + 50

    property alias closeBtnEnabled:close_btn.enabled

    FluIconButton
    {
        id: close_btn
        anchors.top: parent.top
        anchors.right: parent.right
        iconSource: FluentIcons.ChromeCloseContrast
        iconSize: 16
        onClicked: control.close()
    }

    ColumnLayout{
        id:content
        anchors
        {
            centerIn: parent
        }
        spacing: 10

        FluProgressRing
        {
            Layout.alignment: Qt.AlignHCenter
            id: loading_ring_dynamic
            Layout.preferredWidth: 60
            height: Layout.preferredWidth
            visible: true
        }
        FluProgressRing
        {
            Layout.alignment: Qt.AlignHCenter
            id: loading_ring_static
            Layout.preferredWidth: 60
            height: Layout.preferredWidth
            indeterminate: false
            visible: false
        }
        FluMultilineTextBox{
            Layout.preferredWidth: loading_ring_static.visible ? 240 : 120
            horizontalAlignment: Text.Center
            Layout.alignment: Qt.AlignHCenter
            id: loading_text
            font: FluTextStyle.BodyStrong
            background: Rectangle{color:"transparent"}
            readOnly:true
            focus:false
        }
        FluMultilineTextBox{
            Layout.preferredWidth: 240
            horizontalAlignment: Text.Center
            Layout.alignment: Qt.AlignHCenter
            id: loading_post_script
            font: FluTextStyle.Body
            background: Rectangle{color:"transparent"}
            readOnly:true
            focus:false
            visible: false
        }
    }

    Timer{
        id: timer
        triggeredOnStart: false
        function setTimeout(cb, delayTime) {
            timer.interval = delayTime;
            timer.repeat = false;
            timer.triggered.connect(cb);
            timer.triggered.connect(function release () {
                timer.triggered.disconnect(cb); // This is important
                timer.triggered.disconnect(release); // This is important as well
            });
            timer.start();
        }
    }

    function showLoop(text, percent, looping, postscript)
    {
        if (typeof(text)!=='undefined'&&text)
            loading_text.text = text
        if (typeof(percent)!=='undefined')
        {
            if (typeof(looping)!=='undefined')
            {
                loading_ring_static.visible = !looping
                loading_ring_dynamic.visible = looping
                loading_ring_static.progress = percent > 1 ? percent / 100.0 : percent
            }
            else
            {
                loading_ring_static.visible = false
                loading_ring_dynamic.visible = true
                loading_ring_dynamic.progress = percent > 1 ? percent / 100.0 : percent
            }
        }
        else
        {
            loading_ring_static.visible = false
            loading_ring_dynamic.visible = true
        }

        if (typeof(postscript)!=='undefined')
        {
            loading_post_script.text = postscript
            loading_post_script.visible = true
        }
        else
            loading_post_script.visible = false
        if (!control.opened)
            control.open()
    }

    function closeLoopLater(timeout)
    {
        close_btn.visible = false
        timer.setTimeout(function(){
            control.close()
            close_btn.visible = true
        }, timeout)
    }
}
