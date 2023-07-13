import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../../global/network"
import "../global"
import "../../component"

FluContentPage{
    property var filePageRegister: registerForWindowResult("/task_browser")
    launchMode: FluPage.SingleTask
    title: "待办事宜"

    property bool is_search_result: false

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
        loadData(1)
    }

    RowLayout{
        id: search_bar
        anchors{
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 20
        }
        spacing: 14
        FluTextBox{
            id:hqu_oa_file_search
            Layout.preferredWidth:parent.width - hqu_oa_file_search_btn.width - hqu_oa_refresh_btn.width - parent.spacing*2
            placeholderText: "请输入标题关键字"
            iconSource: FluentIcons.Search
        }

        FluFilledButton{
            id:hqu_oa_file_search_btn
            text:"搜索"
            onClicked: {
                is_search_result = (hqu_oa_file_search.text!=='')
                hqu_oa_file_gagination.pageCurrent = 1
                loadData(1)
                showSuccess("搜索"+hqu_oa_file_search.text)
            }
        }

        FluFilledButton{
            id: hqu_oa_refresh_btn
            text: "刷新"
            onClicked: {
                loadData(1)
            }
        }
    }



    FluTableView{
        id:hqu_oa_file_table_view
        anchors{
            left: parent.left
            right: parent.right
            top: search_bar.bottom
            bottom: hqu_oa_file_gagination.top
            topMargin: 20
        }
        columnSource: [
            {
                title: '文件标题',
                dataIndex: '文件标题',
                minimumWidth:250,
                maximumWidth:250,
                width:250,
                readOnly:true
            },
            {
                title: '流程名称',
                dataIndex: '流程名称',
                minimumWidth:60,
                maximumWidth:60,
                width:60,
                readOnly:true
            },
            {
                title: '当前步骤',
                dataIndex: '当前步骤',
                minimumWidth:100,
                maximumWidth:100,
                width:100,
                readOnly:true
            },
            {
                title: '递交人',
                dataIndex: '递交人',
                minimumWidth:60,
                maximumWidth:60,
                width:60,
                readOnly:true
            },
            {
                title: '递交时间',
                dataIndex: '递交时间',
                minimumWidth:100,
                maximumWidth:100,
                width:100,
                readOnly:true
            },
            {
                title: '操作',
                dataIndex: '操作',
                minimumWidth:85,
                maximumWidth:85,
                width:85
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
        __itemPerPage: 10
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
        XmlHttpRequest.ajax("POST", `${HQUPlatformInfo.server_url}/hqu/oa/unprocess_user_files`,
                            function(xhr){
                                //console.log(xhr.status);
                                //console.log(xhr.responseText);
                                var result = JSON.parse(xhr.responseText)
                                if(result.oa_status) {
                                    let data = result.data
                                    if (data.total_files)
                                        hqu_oa_file_gagination.itemCount = data.total_files
                                    else
                                        hqu_oa_file_gagination.itemCount = data.sum

                                    for(let i=0;i<data.files.length;i++){
                                        dataSource.push({
                                                            '文件标题': data.files[i]['文件标题'],
                                                            '流程名称': data.files[i]['流程名称'],
                                                            '当前步骤': data.files[i]['当前步骤'],
                                                            '递交人': data.files[i]['递交人'],
                                                            '递交时间': data.files[i]['递交时间'],
                                                            '操作':hqu_oa_file_com_action,
                                                            height:60,
                                                            minimumHeight:40,
                                                            maximumHeight:200,
                                                        })
                                    }
                                    hqu_oa_file_table_view.dataSource = dataSource
                                    if (!is_search_result)
                                        HQUPlatformInfo.undo_task_num = data.total_files ? data.total_files : data.sum
                                }else{
                                    showError("获取数据失败，请检查网络！")
                                }
                                waitLoop.closeLoopLater(0)
                            },is_search_result?JSON.stringify({username:HQUPlatformInfo.account,token:HQUPlatformInfo.token,page:page,search_word:hqu_oa_file_search.text})
                                              :JSON.stringify({username:HQUPlatformInfo.account,token:HQUPlatformInfo.token,page:page}))
    }
}
