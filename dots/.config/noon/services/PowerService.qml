pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.modules.common

Singleton {
    id: service

    property bool isBattery: true
    property string icon: "eco"
    property string modeName: "Battery"
    property string currentMode: "bat"

    Component.onCompleted: updateMode()

    function updateMode() {
        getModeProcess.running = true;
    }

    function toggleMode() {
        const newMode = isBattery ? "ac" : "bat";
        Quickshell.execDetached([`${Directories.scriptsDir}/tlp_service.sh`, "set", newMode]);
        currentMode = newMode;
        isBattery = (newMode === "bat");
        updateProperties();
    }

    function updateProperties() {
        icon = isBattery ? "eco" : "bolt";
        modeName = isBattery ? "Battery" : "AC";
    }

    Process {
        id: getModeProcess
        command: [`${Directories.scriptsDir}/tlp_service.sh`, "get"]
        running: false
        stdout: SplitParser {
            onRead: line => {
                const trimmed = line.trim();
                if (trimmed === "bat" || trimmed === "ac") {
                    service.currentMode = trimmed;
                    service.isBattery = (trimmed === "bat");
                    service.updateProperties();
                }
            }
        }
    }
}
