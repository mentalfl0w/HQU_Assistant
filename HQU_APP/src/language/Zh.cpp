#include "Zh.h"

Zh::Zh(QObject *parent)
    : Lang{parent}
{
    setObjectName("Zh");
    home("首页");
    fjsjyt("福建省教育厅平台");
    hquoa_common("HQU OA系统 - 常用功能");
    hquid("HQU 统一身份认证平台");
    popus("弹窗");
    navigation("导航");
    theming("主题");
    media("媒体");
    dark_mode("夜间模式");
    search("查找");
    about("关于");
    settings("设置");
    locale("语言环境");
    navigation_view_display_mode("导航视图显示模式");
    style_color("主题颜色");
}
