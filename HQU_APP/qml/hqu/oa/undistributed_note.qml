import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import FluentUI
import "../../global/network"
import "../global"
import "../../component"

FluScrollablePage{
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
        const columns = [
                          {
                              title: '创建时间',
                              dataIndex: 'time',
                              width:100
                          },
                          {
                              title: '标题',
                              dataIndex: 'title',
                              width:180
                          },
                          {
                              title: '姓名',
                              dataIndex: 'name',
                              width:70
                          },
                          {
                              title: '意见',
                              dataIndex: 'remark',
                              width:250
                          },
                          {
                              title: '操作',
                              dataIndex: 'action',
                              width:80
                          }
                      ];
        hqu_oa_file_table_view.columns = columns
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
                                    hqu_oa_file_table_view.itemCount = result.num
                                }else{
                                    showError("获取数据失败，请检查网络！")
                                }
                            },JSON.stringify({username:HQUPlatformInfo.account,token:HQUPlatformInfo.token}))
        loadData(1)
    }

    FluTableViewClassic{
        id:hqu_oa_file_table_view
        Layout.fillWidth: true
        Layout.topMargin: 20
        pageCurrent:1
        pageCount:Math.ceil(itemCount / countperPage)
        property int countperPage:itemCount
        itemCount: 0
        onRequestPage:
            (page)=> {
                loadData(page)
            }
    }

    Component{
        id:hqu_oa_file_com_action
        Item{
            Row{
                anchors.centerIn: parent
                spacing: 10
                FluFilledButton{
                    text:"显示详情"
                    topPadding:3
                    bottomPadding:3
                    leftPadding:3
                    rightPadding:3
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
            if (HQUPlatformInfo.unread_noti != hqu_oa_file_table_view.itemCount)
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
                                    hqu_oa_file_table_view.itemCount = result.sum
                                    for(var i=0;i<result.undistributed.length;i++){
                                        dataSource.push({
                                                            id: result.undistributed[i].id,
                                                            time: result.undistributed[i].time,
                                                            name: result.undistributed[i].user,
                                                            title: result.undistributed[i].title,
                                                            remark: result.undistributed[i].remark,
                                                            action:hqu_oa_file_com_action
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
