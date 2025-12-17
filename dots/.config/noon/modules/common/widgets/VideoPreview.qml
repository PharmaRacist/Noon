import QtMultimedia
import QtQuick

Video {
    id: vid
    muted: true
    loops: 1
    fillMode: VideoOutput.PreserveAspectCrop
    autoPlay: false
}
