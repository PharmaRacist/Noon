pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.modules.common

Item {
    id: root
    required property string url

    property string source: downloaded ? Qt.resolvedUrl(localPath) : ""
    property bool downloaded: false
    property string localDir: Directories.coverArt
    property string fileName: Qt.md5(url) + ".jpg"
    property string localPath: `${localDir}/${fileName}`

    Process {
        id: downloader
        command: [
            "bash", "-c",
            `[ -f "${root.localPath}" ] || curl -sSL "${root.url}" -o "${root.localPath}"`
        ]
        onExited: root.downloaded = true
    }

    onUrlChanged: {
        if (!url || url.length === 0) return
        downloaded = false
        downloader.running = true
    }
}
