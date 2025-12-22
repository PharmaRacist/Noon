pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string text: ""
    property string author: ""

    Process {
        id: fetcher
        command: ["bash", "-c", `${Directories.scriptsDir}/quotes_service.sh`]
        property string output: ""

        stdout: SplitParser {
            onRead: (line) => fetcher.output += line
        }

        onExited: {
            const line = fetcher.output.trim()
            if (line.length > 0 && line.includes("|")) {
                const parts = line.split("|")
                root.text = parts[0].trim()
                root.author = parts[1].trim()
            }
            fetcher.output = ""
        }
    }

    function refresh() {
        fetcher.running = false
        fetcher.running = true
    }
}
