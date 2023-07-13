#ifndef CONFIG_H
#define CONFIG_H

#include <QVariant>
#include <QSettings>
#include <QtCore/QtCore>

class Config : public QSettings
{
    Q_OBJECT
    Q_DISABLE_COPY(Config)
public:
    Config(QString filename = QCoreApplication::applicationDirPath() + "/config.ini", Format format = QSettings::IniFormat);
    Q_INVOKABLE void set(QString,QString,QVariant);
    Q_INVOKABLE QVariant get(QString,QString);
};

#endif // CONFIG_H

