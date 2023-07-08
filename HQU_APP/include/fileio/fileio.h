#ifndef FILEIO_H
#define FILEIO_H

#include <QtCore>

class FileIO : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(FileIO)
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QByteArray content READ content WRITE setContent NOTIFY contentChanged)
public:
    FileIO(QObject *parent = nullptr);
    ~FileIO();

    Q_INVOKABLE void read();
    Q_INVOKABLE void write();
    Q_INVOKABLE QByteArray toBase64(QByteArray btr);
    Q_INVOKABLE QByteArray fromBase64(QByteArray btr);
    QString source() const;
    QByteArray content() const;
public slots:
    void setSource(QString source);
    void setContent(QByteArray content);
signals:
    void sourceChanged(QString arg);
    void contentChanged(QByteArray arg);
private:
    QString m_source;
    QByteArray m_content;
};

#endif // FILEIO_H

