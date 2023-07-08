import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import FluentUI
import "../global/network"
import "global"
import "../component"

FluScrollablePage{
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
        const columns = [
                          {
                              title: '发布时间',
                              dataIndex: 'publish_time',
                              width:100
                          },
                          {
                              title: '文号',
                              dataIndex: 'file_mark',
                              width:80
                          },
                          {
                              title: '文件标题',
                              dataIndex: 'name',
                              width:270
                          },
                          {
                              title: '发布部门',
                              dataIndex: 'unit',
                              width:70
                          },
                          {
                              title: '紧急程度',
                              dataIndex: 'urgency',
                              width:70,
                          },
                          {
                              title: '操作',
                              dataIndex: 'action',
                              width:85
                          }
                      ];
        fjsjyt_file_table_view.columns = columns
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
                                    fjsjyt_file_table_view.itemCount = result.count
                                }else{
                                    showError("获取数据失败，请检查网络！")
                                }
                            },JSON.stringify({username:FJSJYTInfo.account,token:FJSJYTInfo.token}))
        loadData(1)
    }

    Item{
        Layout.fillWidth: true
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
                fjsjyt_file_table_view.pageCurrent = 1
                loadData(1)
                showSuccess("搜索"+fjsjyt_file_search.text)
            }
        }
    }
    FluTableViewClassic{
        id:fjsjyt_file_table_view
        Layout.fillWidth: true
        Layout.topMargin: 20
        pageCurrent:1
        pageCount:Math.ceil(itemCount / countperPage)
        property int countperPage:10
        itemCount: 0
        onRequestPage:
            (page)=> {
                loadData(page)
            }
    }

    Component{
        id:fjsjyt_file_com_action
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
                        filePageRegister.launch({title:dataModel.name,
                                                    page_url:'qrc:/HQU_Assistant/qml/fjsjyt/page/fjsjyt_detail.qml',
                                                    argument:{readed:FJSJYTInfo.is_readed?1:0,unid:dataModel.unid}})
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
            if (FJSJYTInfo.unread_noti != fjsjyt_file_table_view.itemCount)
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
                                        fjsjyt_file_table_view.itemCount = result.sum
                                        for(var i=0;i<result.data.length;i++){
                                            dataSource.push({
                                                                unit: result.data[i].unit,
                                                                publish_time: result.data[i].publish_time,
                                                                name: result.data[i].name,
                                                                file_mark: result.data[i].file_mark,
                                                                unid: result.data[i].unid,
                                                                noteid: result.data[i].noteid,
                                                                urgency: result.data[i].urgency === '124' ? '已签收' : result.data[i].urgency,
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
                                },JSON.stringify({count_per_page:fjsjyt_file_table_view.countperPage,
                                                     start_on_num:(page-1)*fjsjyt_file_table_view.countperPage+1,
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
                        fjsjyt_file_table_view.itemCount = result.count
                        for(var i=0;i<(search_datasource.length >= fjsjyt_file_table_view.countperPage ? fjsjyt_file_table_view.countperPage:search_datasource.length);i++){
                            dataSource.push({
                                                unit: search_datasource[i].unit,
                                                publish_time: search_datasource[i].publish_time,
                                                name: search_datasource[i].name,
                                                file_mark: search_datasource[i].file_mark,
                                                unid: search_datasource[i].unid,
                                                noteid: search_datasource[i].noteid,
                                                urgency: result.data[i].urgency === '124' ? '已签收' : result.data[i].urgency,
                                                action:fjsjyt_file_com_action
                                            })
                        }
                        fjsjyt_file_table_view.dataSource = dataSource
                    }else{
                        showError("获取数据失败，请检查网络！")
                    }
                    waitLoop.closeLoopLater(0)
                },JSON.stringify({count_per_page:fjsjyt_file_table_view.countperPage,
                                     search_word:fjsjyt_file_search.text,
                                     is_readed:FJSJYTInfo.is_readed?1:0,
                                     noteids:noteids,
                                     username:FJSJYTInfo.account,token:FJSJYTInfo.token}))
            }
            else
            {
                for (var i = (page-1)*fjsjyt_file_table_view.countperPage;
                     (i< search_datasource.length)&&(i<page*fjsjyt_file_table_view.countperPage); i++)
                {
                    noteids.push(search_datasource[i]['noteid'])
                }
                XmlHttpRequest.ajax("POST",`${FJSJYTInfo.server_url}/fjsjyt/search`,function(xhr){
                    //console.log(xhr.status);
                    //console.log(xhr.responseText);
                    var result = JSON.parse(xhr.responseText)
                    if(result.search_status) {
                        for(var i = (page-1)*fjsjyt_file_table_view.countperPage;
                            (i< search_datasource.length)&&(i<page*fjsjyt_file_table_view.countperPage); i++)
                        {
                            dataSource.push({
                                                unit: result.data[i - (page-1)*fjsjyt_file_table_view.countperPage].unit,
                                                publish_time: result.data[i - (page-1)*fjsjyt_file_table_view.countperPage].publish_time,
                                                name: result.data[i - (page-1)*fjsjyt_file_table_view.countperPage].name,
                                                file_mark: result.data[i - (page-1)*fjsjyt_file_table_view.countperPage].file_mark,
                                                unid: result.data[i - (page-1)*fjsjyt_file_table_view.countperPage].unid,
                                                noteid: result.data[i - (page-1)*fjsjyt_file_table_view.countperPage].noteid,
                                                urgency: result.data[i].urgency === '124' ? '已签收' : result.data[i].urgency,
                                                action:fjsjyt_file_com_action
                                            })
                            search_datasource[i]['unit'] = result.data[i - (page-1)*fjsjyt_file_table_view.countperPage].unit
                            search_datasource[i]['publish_time'] = result.data[i - (page-1)*fjsjyt_file_table_view.countperPage].publish_time
                            search_datasource[i]['name'] = result.data[i - (page-1)*fjsjyt_file_table_view.countperPage].name
                            search_datasource[i]['file_mark'] = result.data[i - (page-1)*fjsjyt_file_table_view.countperPage].file_mark
                            search_datasource[i]['unid'] = result.data[i - (page-1)*fjsjyt_file_table_view.countperPage].unid
                            search_datasource[i]['noteid'] = result.data[i - (page-1)*fjsjyt_file_table_view.countperPage].noteid
                            search_datasource[i]['urgency'] = result.data[i - (page-1)*fjsjyt_file_gagination.__itemPerPage].urgency === '124' ? '已签收' : result.data[i - (page-1)*fjsjyt_file_gagination.__itemPerPage].urgency
                        }
                        fjsjyt_file_table_view.dataSource = dataSource
                    }else{
                        showError("获取数据失败，请检查网络！")
                    }
                    waitLoop.closeLoopLater(0)
                },JSON.stringify({count_per_page:fjsjyt_file_table_view.countperPage,
                                     search_word:fjsjyt_file_search.text,
                                     is_readed:FJSJYTInfo.is_readed?1:0,
                                     noteids:noteids,
                                     username:FJSJYTInfo.account,token:FJSJYTInfo.token}))
            }
        }
    }
}
