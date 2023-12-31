#include "fileio.h"
#include <QTextCodec>

FileIO::FileIO(QObject *parent)
    : QObject(parent)
{
}

FileIO::~FileIO()
{
}

void FileIO::read()
{
    if(m_source.isEmpty()) {
        return;
    }
    QString url = GetCorrectUnicode(m_source);
    if (url.contains("qrc:/"))
        url.replace("qrc:/", ":/");
    QFile file(url);
    if(!file.exists()) {
        qWarning() << "Does not exits: " << url;
        return;
    }
    if(file.open(QIODevice::ReadOnly)) {
        m_content = file.readAll();
        file.close();
        emit contentChanged(m_content);
    }
}

void FileIO::write()
{
    if(m_source.isEmpty()) {
        return;
    }
    QString url = GetCorrectUnicode(m_source);
    if (url.contains("file:///"))
        url.replace("file:///", "");
    else if(url.contains("file://"))
        url.replace("file://", "");
    QFile file(url);
    if(file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        file.write(m_content);
        file.close();
    }
}

QString FileIO::source() const
{
    return m_source;
}

QByteArray FileIO::content() const
{
    return m_content;
}

void FileIO::setSource(QString source)
{
    if (m_source == source)
        return;

    m_source = source;
    emit sourceChanged(source);
}

void FileIO::setContent(QByteArray content)
{
    if (m_content == content)
        return;

    m_content = content;
    emit contentChanged(content);
}

QByteArray FileIO::toBase64(QByteArray btr)
{
    return btr.toBase64();
}

QByteArray FileIO::fromBase64(QByteArray btr)
{
    return QByteArray::fromBase64(btr);
}

QString FileIO::GetCorrectUnicode(const QByteArray &ba)
{
    QTextCodec::ConverterState state;
    QTextCodec *codec = QTextCodec::codecForName("GB18030");
    QString text = codec->toUnicode( ba.constData(), ba.size(), &state);
    if (state.invalidChars > 0)
    {
        text = QTextCodec::codecForName( "UTF-8" )->toUnicode(ba);
        return text;
    }
    else
    {
        text = ba;
        return text;
    }
}

QString FileIO::GetCorrectUnicode(const QString &ba)
{
    return GetCorrectUnicode(QByteArray(ba.toStdString().data()));
}
