pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.common

Singleton {
    id: root
    property var cursors
    Process {
        id: getProc
        running: true
        command: ["bash", "-c", Directories.scriptsDir + "/get_cursors.sh"]
        stdout: StdioCollector {
            onStreamFinished: root.cursors = text.trim().split("\n")
        }
    }
}
