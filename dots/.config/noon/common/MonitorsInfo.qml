pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.common.widgets

Singleton {
    id: root
    readonly property var monitors: Quickshell.screens
    readonly property Toplevel topLevel: ToplevelManager?.activeToplevel ?? null
    readonly property var focused: monitors.find(s => s.name === Hyprland?.focusedMonitor?.name ?? "") ?? monitors[0] ?? null
    readonly property var focusedScreen: Array.from(focused)
    readonly property var all: monitors
    readonly property var main: monitors.length > 0 ? [monitors[0]] : []
    readonly property var secondary: monitors.length > 1 ? monitors.slice(1) : []

    function monitorFor(panel) {
        return Hyprland.monitorFor(panel);
    }
}
