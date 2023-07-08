#include "AppInfo.h"
#include "language/En.h"
#include "language/Zh.h"
#include <QGuiApplication>
#include <QPalette>
#define STR(x) #x
#define VER_JOIN(a,b,c,d) STR(a.b.c.d)
#define VER_JOIN_(x) VER_JOIN x
#define VER_STR VER_JOIN_((HQUA_VERSION))

AppInfo::AppInfo(QObject *parent)
    : QObject{parent}
{
    version(VER_STR);
    changeLang("Zh");
}

void AppInfo::changeLang(const QString& locale){
    if(_lang){
        _lang->deleteLater();
    }
    if(locale=="Zh"){
        lang(new Zh());
    }else if(locale=="En"){
        lang(new En());
    }else {
        lang(new En());
    }
}
