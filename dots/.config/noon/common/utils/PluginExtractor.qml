import QtQuick
import Quickshell
import qs.common
import qs.common.widgets
import qs.common.functions
import qs.services
import qs.store

Item {
    id: root
    property var plugins
    required property string dir
    property bool active: PluginsManager.enablePlugins
    Loader {
        visible: false
        asynchronous: true
        active: root.active
        sourceComponent: FolderListModel {
            id: folderModel
            showDirs: true
            folder: Qt.resolvedUrl(dir)
            onStatusChanged: getProc.running = true
        }
    }

    Process {
        id: getProc
        running: root.active
        command: ["bash", Directories.scriptsDir + "/plugins_helper.sh", dir, "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.plugins = JSON.parse(text.trim());
                } catch (e) {
                    console.warn("[Plugins] Failed to parse:", e, "\nRaw:", text);
                }
            }
        }
    }
}
