import QtQuick 2.12
import FluentUI 1.0
import FileIO 1.0

FluItem {

    FileIO
    {
        id: file
        source: ''
    }

    function write(data, route, name)
    {
        if (name)
        {
            file.source = Qt.resolvedUrl(route+'/'+name)
            file.content = data
            file.write()
        }
        else
        {
            file.source = Qt.resolvedUrl(route)
            file.content = data
            file.write()
        }
    }

    function read(route, name)
    {
        if(name)
        {
            file.source = Qt.resolvedUrl(route+'/'+name)
            file.read()
            return file.content
        }
        else
        {
            file.source = Qt.resolvedUrl(route)
            file.read()
            return file.content
        }
    }
}
