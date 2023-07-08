pragma Singleton

import QtQuick
import FluentUI
import "qrc:/HQU_Assistant/qml/fjsjyt/global/"
import "qrc:/HQU_Assistant/qml/hqu/global/"

FluObject{

    property var navigationView

    FluPaneItem{
        title:lang.home
        icon:FluentIcons.Home
        onTap:{
            navigationView.push("qrc:/HQU_Assistant/qml/section/Home.qml")
        }
    }

    FluPaneItemExpander{
        title:lang.hquid
        icon:FluentIcons.People
        FluPaneItem{
            title:"账号"
            onTap:{
                navigationView.push("qrc:/HQU_Assistant/qml/hqu/uni_platform/login.qml")
            }
        }
    }

    FluPaneItemExpander{
        title:lang.hquoa
        icon:FluentIcons.FileExplorer
        FluPaneItem{
            title:"待办事宜"
            infoBadge:FluBadge{
                count: HQUPlatformInfo.undo_task_num
                showZero: false
                color: 'green'
            }
            onTap:{
                navigationView.push("qrc:/HQU_Assistant/qml/hquoa/unfinished.qml")
            }
        }
        FluPaneItem{
            title:"已办事宜"
            onTap:{
                navigationView.push("qrc:/HQU_Assistant/qml/hquoa/finished.qml")
            }
        }
        FluPaneItem{
            title:"分发提醒"
            count: HQUPlatformInfo.unread_noti
            infoBadge:FluBadge{
                count: HQUPlatformInfo.unread_noti
                showZero: false
            }
            onTap:{
                navigationView.push("qrc:/HQU_Assistant/qml/hqu/oa/undistributed_note.qml")
            }
        }
    }

    FluPaneItemExpander{
        title:lang.fjsjyt
        icon:FluentIcons.EducationIcon
        FluPaneItem{
            title:"账号"
            onTap:{
                navigationView.push("qrc:/HQU_Assistant/qml/fjsjyt/login.qml")
            }
        }
        FluPaneItem{
            title:"待收文件"
            count: FJSJYTInfo.unread_noti
            infoBadge:FluBadge{
                count: FJSJYTInfo.unread_noti
                showZero: false
            }
            onTap:{
                if(navigationView.getCurrentUrl()==="qrc:/HQU_Assistant/qml/fjsjyt/"+ (FluTools.qtMajor() === 6 ? "file_new.qml" : "file.qml") &&
                   FJSJYTInfo.is_readed === false)
                    return
                FJSJYTInfo.is_readed = false
                navigationView.push("qrc:/HQU_Assistant/qml/fjsjyt/"+ (FluTools.qtMajor() === 6 ? "file_new.qml" : "file.qml"))
            }
        }
        FluPaneItem{
            title:"已收文件"
            onTap:{
                if(navigationView.getCurrentUrl()==="qrc:/HQU_Assistant/qml/fjsjyt/"+ (FluTools.qtMajor() === 6 ? "file_new.qml" : "file.qml") &&
                   FJSJYTInfo.is_readed === true)
                    return
                FJSJYTInfo.is_readed = true
                navigationView.push("qrc:/HQU_Assistant/qml/fjsjyt/"+(FluTools.qtMajor() === 6 ? "file_new.qml" : "file.qml"))
            }
        }
    }

    function getSearchData(){
        var arr = []
        var items = navigationView.getItems();
        for(var i=0;i<items.length;i++){
            var item = items[i]
            if(item instanceof FluPaneItem){
                arr.push({title:item.title,key:item.key})
            }
        }
        return arr
    }

    function startPageByItem(data){
        navigationView.startPageByItem(data)
    }

}
