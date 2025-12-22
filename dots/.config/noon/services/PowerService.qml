pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

Singleton {
    id: root

    property string icon: "eco"
    property string modeName: "Power Saver"
    property string controller: Mem.states.services?.power?.controller || ""
    property var modes: Mem.states.services?.power?.modes || []
    property string currentMode: Mem.states.services?.power?.mode || "power-saver"

    function cycleMode() {
        if (!controller || !modes.length)
            return
        const next = modes[(modes.indexOf(currentMode) + 1) % modes.length]
        Noon.execDetached(["bash", "-c", `${Directories.scriptsDir}/power_service.sh set ${next}`])
    }

    function getModeDisplayName(mode) {
        return { "bat": "Power Saver", "power-saver": "Power Saver", "balanced": "Balanced", "ac": "Performance", "performance": "Performance" }[mode] || mode
    }

    function getModeIcon(mode) {
        return { "bat": "eco", "power-saver": "eco", "balanced": "balance", "ac": "bolt", "performance": "bolt" }[mode] || "eco"
    }

    onCurrentModeChanged: {
        modeName = getModeDisplayName(currentMode)
        icon = getModeIcon(currentMode)
    }
}
