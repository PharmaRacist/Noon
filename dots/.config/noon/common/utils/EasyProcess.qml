import QtQuick
import Quickshell.Io

Process {
    id: root
    property string output: ""
    stdout: StdioCollector {
        onStreamFinished: {
            root.output = text.trim();
        }
    }
}
