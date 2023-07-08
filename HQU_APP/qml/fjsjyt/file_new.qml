import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import FluentUI
import "../global/network"
import "global"
import "../component"

FluContentPage{
    property var filePageRegister: registerForWindowResult("/task_browser")
    launchMode: FluPage.Standard
    title: FJSJYTInfo.is_readed? "已收文件" : "待收文件"

    property bool is_search_result: false
    property var search_datasource: []

    Connections{
        target: filePageRegister
        function onResult(data)
        {
            //console.log(JSON.stringify(data))
            if(data.signin===1)
                loadData(1)
        }
    }

    Connections{
        target: FJSJYTInfo
        function onIs_readedChanged()
        {
            if(!FJSJYTInfo.is_login)
            {
                showError("您尚未登录系统！")
                return
            }
            XmlHttpRequest.ajax("POST",
                                `${FJSJYTInfo.server_url}/fjsjyt/file_count/` + (FJSJYTInfo.is_readed ? 'readed':'unread'),
                                function(xhr){
                                    //console.log(xhr.status);
                                    //console.log(xhr.responseText);
                                    var result = JSON.parse(xhr.responseText)
                                    if(result.count>=0) {
                                        fjsjyt_file_gagination.itemCount = result.count
                                    }else{
                                        showError("获取数据失败，请检查网络！")
                                    }
                                },JSON.stringify({username:FJSJYTInfo.account,token:FJSJYTInfo.token}))
            loadData(1)
        }
    }

    Component.onCompleted: {
        if(!FJSJYTInfo.is_login)
        {
            showError("您尚未登录系统！")
            return
        }
        XmlHttpRequest.ajax("POST",
                            `${FJSJYTInfo.server_url}/fjsjyt/file_count/` + (FJSJYTInfo.is_readed ? 'readed':'unread'),
                            function(xhr){
                                //console.log(xhr.status);
                                //console.log(xhr.responseText);
                                var result = JSON.parse(xhr.responseText)
                                if(result.count>=0) {
                                    fjsjyt_file_gagination.itemCount = result.count
                                }else{
                                    showError("获取数据失败，请检查网络！")
                                }
                            },JSON.stringify({username:FJSJYTInfo.account,token:FJSJYTInfo.token}))
        loadData(1)
    }

    Item{
        id: search_bar
        anchors{
            top: parent.top
            left: parent.left
            right: parent.right
        }

        height: 50
        FluTextBox{
            id:fjsjyt_file_search
            width:parent.width - fjsjyt_file_search_btn.width - 20
            placeholderText: "请输入标题关键字"
            iconSource: FluentIcons.Search
            anchors{
                topMargin: 20
                top:parent.top
            }
        }

        FluFilledButton{
            id:fjsjyt_file_search_btn
            text:"搜索"
            anchors{
                left: fjsjyt_file_search.right
                verticalCenter: fjsjyt_file_search.verticalCenter
                leftMargin: 14
            }
            onClicked: {
                is_search_result = (fjsjyt_file_search.text!=='')
                fjsjyt_file_gagination.pageCurrent = 1
                loadData(1)
                showSuccess("搜索"+fjsjyt_file_search.text)
            }
        }
    }

    FluTableView{
        id:fjsjyt_file_table_view
        anchors{
            left: parent.left
            right: parent.right
            top: search_bar.bottom
            bottom: fjsjyt_file_gagination.top
            topMargin: 20
        }
        columnSource:[
            {
                title: '发布时间',
                dataIndex: 'publish_time',
                width:100,
                minimumWidth:100,
                maximumWidth:100,
                readOnly:true
            },
            {
                title: '文号',
                dataIndex: 'file_mark',
                width:80,
                minimumWidth:80,
                maximumWidth:80,
                readOnly:true
            },
            {
                title: '文件标题',
                dataIndex: 'name',
                width:270,
                minimumWidth:270,
                maximumWidth:270,
                readOnly:true
            },
            {
                title: '发布部门',
                dataIndex: 'unit',
                width:60,
                minimumWidth:60,
                maximumWidth:60,
                readOnly:true
            },
            {
                title: '紧急程度',
                dataIndex: 'urgency',
                width:60,
                minimumWidth:60,
                maximumWidth:60,
                readOnly:true
            },
            {
                title: '操作',
                dataIndex: 'action',
                width:85,
                minimumWidth:85,
                maximumWidth:85,
                readOnly:true
            }
        ]
    }

    FluPagination{
        id:fjsjyt_file_gagination
        anchors{
            bottom:parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        pageCurrent:1
        pageCount:Math.ceil(itemCount / __itemPerPage)
        itemCount: 0
        pageButtonCount: 10
        __itemPerPage: 20
        onRequestPage:
            (page,count)=> {
                fjsjyt_file_table_view.closeEditor()
                loadData(page)
                fjsjyt_file_table_view.resetPosition()
            }
    }

    Component{
        id:fjsjyt_file_com_action
        Item{
            Row{
                anchors.centerIn: parent
                FluTextButton{
                    text:"显示详情"
                    onClicked:{
                        filePageRegister.launch({title:tableModel.getRow(row).name,
                                                    page_url:'qrc:/HQU_Assistant/qml/fjsjyt/page/fjsjyt_detail.qml',
                                                    argument:{readed:FJSJYTInfo.is_readed?1:0,unid:tableModel.getRow(row).unid}})
                        if(!FJSJYTInfo.is_login)
                        {
                            showError("您尚未登录系统！")
                            return
                        }
                        //console.debug(dataModel.index)
                    }
                }
            }
        }
    }

    Connections{
        target: FJSJYTInfo
        enabled: !FJSJYTInfo.is_readed
        function onNeed_fetch_noti()
        {
            if (FJSJYTInfo.unread_noti != fjsjyt_file_gagination.itemCount)
            {
                loadData(1)
            }
        }
    }

    function loadData(page){
        if(!FJSJYTInfo.is_login)
        {
            showError("您尚未登录系统！")
            return
        }
        waitLoop.showLoop("加载中···")
        const dataSource = []
        if (!is_search_result)
        {
            XmlHttpRequest.ajax("POST",
                                `${FJSJYTInfo.server_url}/fjsjyt/` + (FJSJYTInfo.is_readed? 'readed':'unread'),
                                function(xhr){
                                    //console.log(xhr.status);
                                    //console.log(xhr.responseText);
                                    var result = JSON.parse(xhr.responseText)
                                    if(FJSJYTInfo.is_readed? result.readed_files_status:result.unread_files_status) {
                                        fjsjyt_file_gagination.itemCount = result.sum
                                        for(var i=0;i<result.data.length;i++){
                                            dataSource.push({
                                                                unit: result.data[i].unit,
                                                                publish_time: result.data[i].publish_time,
                                                                name: result.data[i].name,
                                                                file_mark: result.data[i].file_mark,
                                                                unid: result.data[i].unid,
                                                                noteid: result.data[i].noteid,
                                                                urgency: result.data[i].urgency === '124' ? '已签收' : result.data[i].urgency,
                                                                height:60,
                                                                minimumHeight:40,
                                                                maximumHeight:200,
                                                                action:fjsjyt_file_com_action
                                                            })
                                        }
                                        fjsjyt_file_table_view.dataSource = dataSource
                                        if(!FJSJYTInfo.is_readed)
                                        {
                                            FJSJYTInfo.unread_noti = result.sum
                                        }
                                    }else{
                                        showError("获取数据失败，请检查网络！")
                                    }
                                    waitLoop.closeLoopLater(0)
                                },JSON.stringify({count_per_page:fjsjyt_file_gagination.__itemPerPage,
                                                     start_on_num:(page-1)*fjsjyt_file_gagination.__itemPerPage+1,
                                                     username:FJSJYTInfo.account,token:FJSJYTInfo.token}))
        }
        else
        {
            const noteids = []
            if (page===1)
            {
                XmlHttpRequest.ajax("POST",`${FJSJYTInfo.server_url}/fjsjyt/search`,function(xhr){
                    //console.log(xhr.status);
                    //console.log(xhr.responseText);
                    var result = JSON.parse(xhr.responseText)
                    if(result.search_status) {
                        search_datasource = result.data
                        fjsjyt_file_gagination.itemCount = result.count
                        for(var i=0;i<(search_datasource.length >= fjsjyt_file_gagination.__itemPerPage ? fjsjyt_file_gagination.__itemPerPage:search_datasource.length);i++){
                            dataSource.push({
                                                unit: search_datasource[i].unit,
                                                publish_time: search_datasource[i].publish_time,
                                                name: search_datasource[i].name,
                                                file_mark: search_datasource[i].file_mark,
                                                unid: search_datasource[i].unid,
                                                noteid: search_datasource[i].noteid,
                                                urgency: result.data[i].urgency === '124' ? '已签收' : result.data[i].urgency,
                                                height:60,
                                                minimumHeight:40,
                                                maximumHeight:200,
                                                action:fjsjyt_file_com_action
                                            })
                        }
                        fjsjyt_file_table_view.dataSource = dataSource
                    }else{
                        showError("获取数据失败，请检查网络！")
                    }
                    waitLoop.closeLoopLater(0)
                },JSON.stringify({count_per_page:fjsjyt_file_gagination.__itemPerPage,
                                     search_word:fjsjyt_file_search.text,
                                     is_readed:FJSJYTInfo.is_readed?1:0,
                                     noteids:noteids,
                                     username:FJSJYTInfo.account,token:FJSJYTInfo.token}))
            }
            else
            {
                for (var i = (page-1)*fjsjyt_file_gagination.__itemPerPage;
                     (i< search_datasource.length)&&(i<page*fjsjyt_file_gagination.__itemPerPage); i++)
                {
                    noteids.push(search_datasource[i]['noteid'])
                }
                XmlHttpRequest.ajax("POST",`${FJSJYTInfo.server_url}/fjsjyt/search`,function(xhr){
                    //console.log(xhr.status);
                    //console.log(xhr.responseText);
                    var result = JSON.parse(xhr.responseText)
                    if(result.search_status) {
                        for(var i = (page-1)*fjsjyt_file_gagination.__itemPerPage;
                            (i< search_datasource.length)&&(i<page*fjsjyt_file_gagination.__itemPerPage); i++)
                        {
                            dataSource.push({
                                                unit: result.data[i - (page-1)*fjsjyt_file_gagination.__itemPerPage].unit,
                                                publish_time: result.data[i - (page-1)*fjsjyt_file_gagination.__itemPerPage].publish_time,
                                                name: result.data[i - (page-1)*fjsjyt_file_gagination.__itemPerPage].name,
                                                file_mark: result.data[i - (page-1)*fjsjyt_file_gagination.__itemPerPage].file_mark,
                                                unid: result.data[i - (page-1)*fjsjyt_file_gagination.__itemPerPage].unid,
                                                noteid: result.data[i - (page-1)*fjsjyt_file_gagination.__itemPerPage].noteid,
                                                urgency: result.data[i].urgency === '124' ? '已签收' : result.data[i].urgency,
                                                height:60,
                                                minimumHeight:40,
                                                maximumHeight:200,
                                                action:fjsjyt_file_com_action
                                            })
                            search_datasource[i]['unit'] = result.data[i - (page-1)*fjsjyt_file_gagination.__itemPerPage].unit
                            search_datasource[i]['publish_time'] = result.data[i - (page-1)*fjsjyt_file_gagination.__itemPerPage].publish_time
                            search_datasource[i]['name'] = result.data[i - (page-1)*fjsjyt_file_gagination.__itemPerPage].name
                            search_datasource[i]['file_mark'] = result.data[i - (page-1)*fjsjyt_file_gagination.__itemPerPage].file_mark
                            search_datasource[i]['unid'] = result.data[i - (page-1)*fjsjyt_file_gagination.__itemPerPage].unid
                            search_datasource[i]['noteid'] = result.data[i - (page-1)*fjsjyt_file_gagination.__itemPerPage].noteid
                            search_datasource[i]['urgency'] = result.data[i - (page-1)*fjsjyt_file_gagination.__itemPerPage].urgency === '124' ? '已签收' : result.data[i - (page-1)*fjsjyt_file_gagination.__itemPerPage].urgency
                        }
                        fjsjyt_file_table_view.dataSource = dataSource
                    }else{
                        showError("获取数据失败，请检查网络！")
                    }
                    waitLoop.closeLoopLater(0)
                },JSON.stringify({count_per_page:fjsjyt_file_gagination.__itemPerPage,
                                     search_word:fjsjyt_file_search.text,
                                     is_readed:FJSJYTInfo.is_readed?1:0,
                                     noteids:noteids,
                                     username:FJSJYTInfo.account,token:FJSJYTInfo.token}))
            }
        }
    }
}
