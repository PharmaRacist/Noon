import QtQuick
import qs.common
import qs.common.widgets
import qs.common.functions

Image {
    id: fgImage
    z: 9999
    anchors.fill: bgImage
    fillMode: Image.PreserveAspectCrop
    source: FileUtils.trimFileProtocol(Directories.wallpapers.depthDir + Qt.md5(FileUtils.trimFileProtocol(Mem.states.desktop.bg.currentBg)) + ".png")
    asynchronous: true
    cache: true
    mipmap: true
    sourceSize: bgImage.sourceSize
    x: bgImage.x
    y: bgImage.y
    function refresh() {
        fgImage.source = "";
        fgImage.source = FileUtils.trimFileProtocol(Directories.wallpapers.depthDir + Qt.md5(FileUtils.trimFileProtocol(Mem.states.desktop.bg.currentBg)) + ".png");
    }
    opacity: fgImage.status === Image.Ready ? 1 : 0
    Behavior on opacity {
        Anim {}
    }
}
