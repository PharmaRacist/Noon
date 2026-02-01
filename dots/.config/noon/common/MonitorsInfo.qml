pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Singleton {
    id: root
    readonly property var topLevel: ToplevelManager.activeToplevel
    readonly property var focused: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor.name)
    readonly property var all: Quickshell.screens
    readonly property var main: Quickshell.screen[0]
    readonly property var secondary: Quickshell.screen.split(1)
}
