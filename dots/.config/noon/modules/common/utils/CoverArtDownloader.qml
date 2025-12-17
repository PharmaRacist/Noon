pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.modules.common

Item {
    id: root
    visible:active
    required property string url
    property bool active: false
    property string source: downloaded ? Qt.resolvedUrl(localPath) : ""
    property bool downloaded: false
    property string localDir: Directories.coverArt
    property string fileName: Qt.md5(url) + ".jpg"
    property string localPath: `${localDir}/${fileName}`

    Timer {
        id: safeExitTimer
        interval: 100
        onTriggered: root.downloaded = true
    }
    Process {
        id: downloader
        command: ["bash", "-c", `[ -f "${root.localPath}" ] || curl -sSL "${root.url}" -o "${root.localPath}"`]
        onExited: safeExitTimer.restart()
    }

    onUrlChanged: {
        if (active && (!url || url.length === 0))
            return;
        downloaded = false;
        downloader.running = true;
    }
}
