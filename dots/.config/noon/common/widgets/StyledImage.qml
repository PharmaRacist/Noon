import QtQuick
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services

Image {
    property int implicitSize: 48
    width: implicitSize
    height: implicitSize
    mipmap: true
    cache: true
    antialiasing: true
    fillMode: Image.PreserveAspectCrop
    sourceSize: Qt.size(width, height)
    asynchronous: true
    retainWhileLoading: true
    visible: opacity > 0
    opacity: status === Image.Ready ? 1 : 0

    Behavior on opacity {
        Anim {}
    }
}
