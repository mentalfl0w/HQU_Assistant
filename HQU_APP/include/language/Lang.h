﻿#ifndef LANG_H
#define LANG_H

#include <QObject>
#include "stdafx.h"

class Lang : public QObject
{
    Q_OBJECT
    Q_PROPERTY_AUTO(QString,home);
    Q_PROPERTY_AUTO(QString,fjsjyt);
    Q_PROPERTY_AUTO(QString,hquoa);
    Q_PROPERTY_AUTO(QString,hquid);
    Q_PROPERTY_AUTO(QString,popus);
    Q_PROPERTY_AUTO(QString,navigation);
    Q_PROPERTY_AUTO(QString,theming);
    Q_PROPERTY_AUTO(QString,media);
    Q_PROPERTY_AUTO(QString,dark_mode);
    Q_PROPERTY_AUTO(QString,search);
    Q_PROPERTY_AUTO(QString,about);
    Q_PROPERTY_AUTO(QString,settings);
    Q_PROPERTY_AUTO(QString,navigation_view_display_mode);
    Q_PROPERTY_AUTO(QString,locale);
public:
    explicit Lang(QObject *parent = nullptr);

};

#endif // LANG_H
