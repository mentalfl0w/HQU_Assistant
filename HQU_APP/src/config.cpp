#include "config.h"
#include <QDebug>

Config::Config(QString filename,Format format)
    : QSettings(filename, format)
{
}

void Config::set(QString qstrnodename,QString qstrkeyname,QVariant qvarvalue)
{
    setValue(QString("/%1/%2").arg(qstrnodename).arg(qstrkeyname), qvarvalue);
}

QVariant Config::get(QString qstrnodename,QString qstrkeyname)
{
    QVariant qvar = value(QString("/%1/%2").arg(qstrnodename).arg(qstrkeyname));
    return qvar;
}
