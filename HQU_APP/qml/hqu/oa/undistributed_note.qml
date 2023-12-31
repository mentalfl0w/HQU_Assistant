﻿import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import FluentUI
import "../../global/network"
import "../global"
import "../../component"

FluContentPage{
    property var filePageRegister: registerForWindowResult("/task_browser")
    launchMode: FluPage.SingleTask
    title: "分发提醒"

    Connections{
        target: filePageRegister
        function onResult(data)
        {
            //console.log(JSON.stringify(data))
            if(data.signin===1)
                loadData(1)
        }
    }

    Component.onCompleted: {
        if(!HQUPlatformInfo.is_login)
        {
            showError("您尚未登录系统！")
            return
        }
        XmlHttpRequest.ajax("POST", `${HQUPlatformInfo.server_url}/hqu/oa/undistributed_note_num`,
                            function(xhr){
                                //console.log(xhr.status);
                                //console.log(xhr.responseText);
                                var result = JSON.parse(xhr.responseText)
                                if(result.num>=0) {
                                    hqu_oa_file_gagination.itemCount = result.num
                                }else{
                                    showError("获取数据失败，请检查网络！")
                                }
                            },JSON.stringify({username:HQUPlatformInfo.account,token:HQUPlatformInfo.token}))
        loadData(1)
    }

    FluFilledButton{
        id: hqu_oa_refresh_btn
        text: "刷新"
        anchors{
            top:parent.top
            right: parent.right
        }
        onClicked: {
            loadData(1)
        }
    }

    FluTableView{
        id:hqu_oa_file_table_view
        anchors{
            left: parent.left
            right: parent.right
            top: hqu_oa_refresh_btn.bottom
            bottom: hqu_oa_file_gagination.top
            topMargin: 20
        }
        columnSource: [
            {
                title: '创建时间',
                dataIndex: 'time',
                minimumWidth:100,
                maximumWidth:100,
                width:100,
                readOnly:true
            },
            {
                title: '标题',
                dataIndex: 'title',
                minimumWidth:180,
                maximumWidth:180,
                width:180,
                readOnly:true
            },
            {
                title: '姓名',
                dataIndex: 'name',
                minimumWidth:60,
                maximumWidth:60,
                width:60,
                readOnly:true
            },
            {
                title: '意见',
                dataIndex: 'remark',
                minimumWidth:235,
                maximumWidth:235,
                width:235,
                readOnly:true
            },
            {
                title: '操作',
                dataIndex: 'action',
                minimumWidth:80,
                maximumWidth:80,
                width:80,
                readOnly:true
            }
        ];
    }

    FluPagination{
        id:hqu_oa_file_gagination
        anchors{
            bottom:parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        pageCurrent:1
        pageCount:Math.ceil(itemCount / __itemPerPage)
        itemCount: 0
        pageButtonCount: 10
        __itemPerPage: 1000
        onRequestPage:
            (page,count)=> {
                hqu_oa_file_table_view.closeEditor()
                loadData(page)
                hqu_oa_file_table_view.resetPosition()
            }
    }

    Component{
        id:hqu_oa_file_com_action
        Item{
            Row{
                anchors.centerIn: parent
                spacing: 10
                FluTextButton{
                    text:"显示详情"
                    onClicked:{
                        if(!HQUPlatformInfo.is_login)
                        {
                            showError("您尚未登录系统！")
                            return
                        }
                        showInfo("正在施工中……")
                        /*filePageRegister.launch({title:dataModel.name,
                                                    page_url:'qrc:/HQU_Assistant/qml/hqu_oa/page/hqu_oa_detail.qml',
                                                    argument:{readed:HQUPlatformInfo.is_readed?1:0,unid:dataModel.unid}})*/
                        //console.debug(dataModel.index)
                    }
                }
            }
        }
    }

    Connections{
        target: HQUPlatformInfo
        function onNeed_fetch_noti()
        {
            if (HQUPlatformInfo.unread_noti !== hqu_oa_file_gagination.itemCount)
            {
                loadData(1)
            }
        }
    }

    function loadData(page){
        if(!HQUPlatformInfo.is_login)
        {
            showError("您尚未登录系统！")
            return
        }
        waitLoop.showLoop("加载中···")
        const dataSource = []
        XmlHttpRequest.ajax("POST", `${HQUPlatformInfo.server_url}/hqu/oa/undistributed_note`,
                            function(xhr){
                                //console.log(xhr.status);
                                //console.log(xhr.responseText);
                                var result = JSON.parse(xhr.responseText)
                                if(result.oa_status) {
                                    hqu_oa_file_gagination.itemCount = result.sum
                                    for(var i=0;i<result.undistributed.length;i++){
                                        dataSource.push({
                                                            id: result.undistributed[i].id,
                                                            time: result.undistributed[i].time,
                                                            name: result.undistributed[i].user,
                                                            title: result.undistributed[i].title,
                                                            remark: result.undistributed[i].remark,
                                                            action:hqu_oa_file_com_action,
                                                            height:60,
                                                            minimumHeight:40,
                                                            maximumHeight:200,
                                                        })
                                    }
                                    hqu_oa_file_table_view.dataSource = dataSource
                                    HQUPlatformInfo.unread_noti = result.sum
                                }else{
                                    showError("获取数据失败，请检查网络！")
                                }
                                waitLoop.closeLoopLater(0)
                            },JSON.stringify({username:HQUPlatformInfo.account,token:HQUPlatformInfo.token}))
    }
}
