pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Singleton {
    id: root
    readonly property var monitors: Quickshell?.screens ?? []
    readonly property Toplevel topLevel: ToplevelManager.activeToplevel
    readonly property var focused: monitors?.find(s => s.name === Hyprland?.focusedMonitor?.name)
    readonly property var all: monitors
    readonly property var main: monitors[0]
    readonly property var secondary: monitors.length > 1 ? monitors.slice(1) : []

    function monitorFor(panel){
        return Hyprland.monitorFor(panel)
    }
}
