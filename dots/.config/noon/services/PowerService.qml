pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

Singleton {
    id: root

    property string icon: "eco"
    property string modeName: "Battery"
    property string controller: ""
    property var modes: []
    property int currentModeIndex: 0
    property bool isReady: false

    function updateMode() {
        if (!controller || !isReady) return;
        getModeProcess.command = ["bash", "-c", `${Directories.scriptsDir}/power_service.sh ${controller} get`];
        getModeProcess.running = true;
    }

    function cycleMode(arg) {
        if (!controller || modes.length === 0 || !isReady) {
            console.warn("Power service not ready or no controller found");
            return;
        }

        currentModeIndex = (currentModeIndex + 1) % modes.length;
        const newMode = modes[currentModeIndex];
        const cmd = ["bash","-c",`${Directories.scriptsDir}/power_service.sh ${controller} set ${newMode}`]
        Noon.execDetached(cmd);
        updateModeProperties(newMode);
        Noon.notify("Power Service", `Changed Power Mode to ${modeName}`);
    }

    function updateModeProperties(mode) {
        if (!mode) return;

        switch(mode) {
            case "bat":
            case "power-saver":
                icon = "eco";
                modeName = "Power Saver";
                break;
            case "balanced":
                icon = "balance";
                modeName = "Balanced";
                break;
            case "ac":
            case "performance":
                icon = "bolt";
                modeName = "Performance";
                break;
            default:
                console.warn("Unknown power mode:", mode);
                icon = "help";
                modeName = "Unknown";
        }
    }

    Component.onCompleted: {
        getControllerProcess.running = true;
    }

    // Detect controller
    Process {
        id: getControllerProcess
        command: ["bash", "-c", "command -v tlp || command -v power-profiles-daemon || command -v auto-cpufreq"]

        stdout: SplitParser {
            onRead: line => {
                if (line.length > 1) {
                    const path = line.trim();
                    root.controller = path.split('/').pop();

                    if (root.controller) {
                        Mem.states.services.power.controller = root.controller;

                        // Set available modes based on controller
                        switch(root.controller) {
                            case "tlp":
                                root.modes = ["bat", "ac"];
                                break;
                            case "power-profiles-daemon":
                                root.modes = ["power-saver", "balanced", "performance"];
                                break;
                            case "auto-cpufreq":
                                root.modes = ["bat", "ac"];
                                break;
                            default:
                                console.warn("Unknown controller:", root.controller);
                                root.modes = [];
                                return;
                        }

                        root.isReady = true;
                        root.updateMode();
                    }
                }
            }
        }

        onExited: (code, status) => {
            if (code !== 0) {
                console.error("Failed to detect power controller");
                root.isReady = false;
            }
        }
    }

    // Get current mode
    Process {
        id: getModeProcess
        running: false

        stdout: SplitParser {
            onRead: line => {
                const mode = line.trim();
                if (mode) {
                    const index = root.modes.indexOf(mode);
                    if (index !== -1) {
                        root.currentModeIndex = index;
                        root.updateModeProperties(mode);
                    } else {
                        console.warn("Received unknown mode:", mode);
                    }
                }
            }
        }

        onExited: (code, status) => {
            if (code !== 0) {
                console.error("Failed to get current power mode");
            }
        }
    }

    // Auto-update timer
    Timer {
        interval: 30000
        running: root.isReady && root.controller !== ""
        repeat: true
        onTriggered: root.updateMode()
    }
}
