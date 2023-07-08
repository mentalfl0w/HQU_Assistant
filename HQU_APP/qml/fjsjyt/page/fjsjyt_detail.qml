import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import Qt.labs.platform
import QtQuick.Layouts
import QtQuick.Window
import FluentUI
import FileIO
import "../../global/network"
import "../global"

FluScrollablePage{
    id:window
    property string unid: ''

    property var argument:parent.argument

    Component.onCompleted: {
        //console.log(JSON.stringify(argument))
        unid = argument.unid
        get_detail(argument.unid,argument.readed===1)
    }

    FluContentDialog
    {
        id:sign_in
        title:"签收"
        message:"确定要签收吗？"
        negativeText:"取消"
        buttonFlags: FluContentDialog.NegativeButton | FluContentDialog.PositiveButton
        onNegativeClicked:{
            close()
        }
        positiveText:"签收"
        onPositiveClicked:{
            XmlHttpRequest.ajax("POST",`${FJSJYTInfo.server_url}/fjsjyt/signin`,function(xhr){
                //console.log(xhr.status);
                //console.log(xhr.responseText);
                var resp = JSON.parse(xhr.responseText)
                if(resp.files_signin_status===1) {
                    showSuccess("签收成功！")
                    waitLoop.showLoop("签收成功！",100)
                    waitLoop.closeLoopLater(2000)
                    onResult({unid:unid, signin: 1})
                    get_detail(unid,true)
                }else{
                    showError("签收失败，请检查网络！")
                    waitLoop.showLoop("签收失败，请检查网络！",0)
                    waitLoop.closeLoopLater(2000)
                }
            }, JSON.stringify({username:FJSJYTInfo.account,token:FJSJYTInfo.token,unid:unid}))
        }
        blurSource: window
        blurRectY: y - 30 - 30
    }

    ColumnLayout
    {
        id: view
        Layout.fillWidth: true
        FluArea{
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            paddings: 10
            height: title.contentHeight + 20
            Layout.topMargin: 20
            Layout.leftMargin : 20
            Layout.rightMargin: 20
            FluCopyableText{
                anchors{
                    centerIn: parent
                }
                width: parent.width
                id: title
                text:"标题："
                font:  FluTextStyle.Title
                wrapMode: Text.WrapAnywhere
                Layout.alignment: Qt.AlignHCenter
            }
        }

        FluArea{
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            paddings: 10
            height: file_mark.contentHeight + 20
            Layout.topMargin: 10
            Layout.leftMargin : 20
            Layout.rightMargin: 20
            FluCopyableText{
                anchors{
                    centerIn: parent
                }
                width: parent.width
                id: file_mark
                text:"文号："
                font:  FluTextStyle.Subtitle
                wrapMode: Text.WrapAnywhere
                Layout.alignment: Qt.AlignHCenter
            }
        }

        RowLayout{
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            Layout.leftMargin : 20
            Layout.rightMargin: 20
            FluArea{
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                paddings: 10
                height: unit.contentHeight + 20
                FluCopyableText{
                    id:unit
                    width: parent.width
                    text:"部门："
                    font:  FluTextStyle.Body
                    wrapMode: Text.WrapAnywhere
                }
            }
            FluArea{
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                paddings: 10
                height: public_p.contentHeight + 20
                FluCopyableText{
                    width: parent.width
                    id: public_p
                    text:"公开属性："
                    font:  FluTextStyle.Body
                    wrapMode: Text.WrapAnywhere
                }
            }
            FluArea{
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                paddings: 10
                height: priotity.contentHeight + 20
                FluCopyableText{
                    width: parent.width
                    id: priotity
                    text:"缓急："
                    font:  FluTextStyle.Body
                    wrapMode: Text.WrapAnywhere
                }
            }

        }

        FluArea{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            height: pub_note.contentHeight + 20
            paddings: 10
            Layout.topMargin: 10
            Layout.leftMargin : 20
            Layout.rightMargin: 20
            FluCopyableText{
                id: pub_note
                width: parent.width
                text:"发布说明："
                font:  FluTextStyle.Caption
                wrapMode: Text.WrapAnywhere
            }
        }

        FluArea{
            id: signin_note_area
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            height: signin_note.contentHeight + 20
            paddings: 10
            Layout.topMargin: 10
            Layout.leftMargin : 20
            Layout.rightMargin: 20
            FluCopyableText{
                id: signin_note
                width: parent.width
                text:"签收说明："
                font:  FluTextStyle.Caption
                wrapMode: Text.WrapAnywhere
            }
        }

        FluFilledButton{
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            text:"签收"
            id: signin_btn
            onClicked:{
                sign_in.open()
            }
        }

        FluExpander{
            headerText:"附件"
            Layout.fillWidth: true
            Layout.topMargin: 10
            Layout.leftMargin : 20
            Layout.rightMargin: 20
            Layout.bottomMargin: 20
            contentHeight: attachment_list.contentHeight + 30
            ListView {
                id: attachment_list
                anchors{
                    top: parent.top
                    left: parent.left
                    fill: parent
                    margins: 10
                }
                spacing: anchors.margins
                orientation: ListView.Vertical
                footer: ColumnLayout{
                    width:parent.width
                    height:download_all_btn.height
                    Layout.fillWidth: true
                    FluFilledButton{
                        text:"下载全部"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: parent.spacing * 2
                        id: download_all_btn
                        onClicked:{
                            fds_all.open()
                        }

                        FolderDialog {
                            id:fds_all
                            title: "选择下载文件夹"
                            currentFolder: "/"
                            onAccepted: {
                                for (var i=0;i<model_attachment.count;i++)
                                {
                                    waitLoop.showLoop(`下载附件（${i+1} / ${model_attachment.count}）`)
                                    var model = model_attachment.get(i)
                                    //console.log(model.url,model.title)
                                    download_files(currentFolder, model.url, model.title)
                                }
                            }

                            onRejected: {
                                showInfo("取消下载...");
                            }
                        }
                    }
                }
                model: ListModel{
                    id:model_attachment
                    ListElement{
                        title:"附件标题附件标题附件标题附件标题附件标题附件标题附件标题附件标题附件标题附件标题附件标题附件标题附件标题附件标题"
                        url:"https://github.com/zhuzichu520/FluentUI"
                    }
                    ListElement{
                        title:"附件标题附件标题附件标题附件标题附件标题附件标题附件标题附件标题附件标题附件标题附件标题附件标题附件标题附件标题"
                        url:"https://github.com/zhuzichu520/FluentUI"
                    }
                }
                ScrollBar.vertical: FluScrollBar{
                    id: scrollbar_attachment
                }
                clip: false
                delegate:
                    RowLayout{
                    FluCopyableText{
                        id: index_text
                        text: (index+1) + ': '
                        font:  FluTextStyle.Body
                        Layout.margins: 5
                    }
                    FluArea{
                        radius: 8
                        width: window.width - index_text.width - 100
                        height: rlayout.height
                        Rectangle{
                            anchors.fill: parent
                            radius: 8
                            color:{
                                if(FluTheme.dark){
                                    if(item_mouse.containsMouse){
                                        return Qt.rgba(1,1,1,0.03)
                                    }
                                    return Qt.rgba(0,0,0,0)
                                }else{
                                    if(item_mouse.containsMouse){
                                        return Qt.rgba(0,0,0,0.03)
                                    }
                                    return Qt.rgba(0,0,0,0)
                                }
                            }
                        }
                        FluTooltip{
                            visible: item_mouse.containsMouse
                            text:model.title+'.'+model.url.match(/\.([^.]+)$/)[1]
                            delay: 1000
                        }
                        RowLayout{
                            id: rlayout
                            spacing: -10
                            FluIcon {
                                Layout.margins: 10
                                iconSource: FluentIcons.Attach
                                iconSize: 15
                            }
                            FluMultilineTextBox{
                                text: model.title+'.'+model.url.match(/\.([^.]+)$/)[1]
                                font:  FluTextStyle.Body
                                Layout.margins: 10
                                background: Rectangle{color:'transparent'}
                                focus:false
                                readOnly:true
                                width: window.width - index_text.width - 135
                            }
                        }

                        MouseArea{
                            id:item_mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onWheel: (wheel)=>{
                                         if (wheel.angleDelta.y > 0) scrollbar_attachment.decrease()
                                         else scrollbar_attachment.increase()
                                     }
                            onClicked: {
                                fds.open()
                            }

                            FolderDialog {
                                id:fds
                                title: "选择下载文件夹"
                                currentFolder: "/"
                                onAccepted: {
                                    waitLoop.showLoop(`正在下载附件`)
                                    download_files(currentFolder, model.url, model.title)
                                }

                                onRejected: {
                                    showInfo("取消下载...");
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function update_attachment_list(a_list){
        model_attachment.clear()
        var data = []
        for (var i=0; i< a_list.length; i++){
            data.push({
                          title:a_list[i].name,
                          url:a_list[i].url
                      })
        }
        model_attachment.append(data)
    }

    function get_detail(key, is_readed){
        waitLoop.showLoop("加载中···")
        if (is_readed)
        {
            signin_btn.visible = false
            signin_note_area.visible = true;
            XmlHttpRequest.ajax("POST",`${FJSJYTInfo.server_url}/fjsjyt/file_detail/readed`,function(xhr){
                //console.log(xhr.status);
                //console.log(xhr.responseText);
                var resp = JSON.parse(xhr.responseText)
                if(resp.readed_files_status===1) {
                    resp = resp.data
                    title.text = resp.name
                    file_mark.text = "文号："+resp.file_mark
                    unit.text = "部门：" + resp.unit
                    public_p.text = "公开属性："+resp.public_p
                    priotity.text = "缓急："+resp.priority
                    pub_note.text = "发布说明："+resp.publish_note
                    signin_note.text = "签收说明："+resp.signin_note
                    update_attachment_list(resp.attachments)

                }else{
                    showError("获取数据失败，请检查网络！")
                }
                waitLoop.closeLoopLater(0)
            }, JSON.stringify({username:FJSJYTInfo.account,token:FJSJYTInfo.token,unid:key}))
        }
        else
        {
            signin_note_area.visible = false;
            XmlHttpRequest.ajax("POST",`${FJSJYTInfo.server_url}/fjsjyt/file_detail/unread`,function(xhr){
                //console.log(xhr.status);
                //console.log(xhr.responseText);
                var resp = JSON.parse(xhr.responseText)
                if(resp.unread_files_status===1) {
                    resp = resp.data
                    title.text = resp.name
                    file_mark.text = "文号："+resp.file_mark
                    unit.text = "部门：" + resp.unit
                    public_p.text = "公开属性："+resp.public_p
                    priotity.text = "缓急："+resp.priority
                    pub_note.text = "发布说明："+resp.publish_note
                    update_attachment_list(resp.attachments)
                }else{
                    showError("获取数据失败，请检查网络！")
                }
                waitLoop.closeLoopLater(0)
            }, JSON.stringify({username:FJSJYTInfo.account,token:FJSJYTInfo.token,unid:key}))
        }
    }

    function download_files(currentFolder, url, title){
        showSuccess("文件将下载至：" + currentFolder, 5000);
        waitLoop.closeBtnEnabled = false
        XmlHttpRequest.ajax("GET",url,function(xhr){
            //console.log(xhr.status);
            file_mng.write(xhr.responseContent, `${currentFolder}/${title}.${url.match(/\.([^.]+)$/)[1]}`)
            waitLoop.closeBtnEnabled = true
        }, '',
        {
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 Edg/112.0.1722.34",
            "Cookie": FJSJYTInfo.cookie
        },function(sentBytes, totalBytes){
            if (sentBytes !== totalBytes)
            {
                waitLoop.showLoop(undifined,sentBytes/totalBytes,false,`${title}.${url.match(/\.([^.]+)$/)[1]} (${sentBytes}/${totalBytes})`)
            }
            else
            {
                waitLoop.showLoop(undefined,sentBytes/totalBytes,false,`${title}.${url.match(/\.([^.]+)$/)[1]} (${sentBytes}/${totalBytes})`)
            }
        })
    }

}
