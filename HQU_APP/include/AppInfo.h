#ifndef APPINFO_H
#define APPINFO_H

#include <QObject>
#include <QEvent>
#include "language/Lang.h"
#include "stdafx.h"

class AppInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY_AUTO(QString,version)
    Q_PROPERTY_AUTO(Lang*,lang)
    Q_PROPERTY_AUTO(bool,current_theme)
public:
    explicit AppInfo(QObject *parent = nullptr);
    Q_INVOKABLE void changeLang(const QString& locale);
};

#endif // APPINFO_H
