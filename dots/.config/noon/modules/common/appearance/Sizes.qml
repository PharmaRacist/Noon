import QtQuick
import Quickshell
import qs.services
import qs.modules.common

QtObject {
    property real barElevation: hyprlandGapsOut / 4
    property real osdWidth: 220
    property real osdHeight: 45
    property real collapsedSideBarWidth: 50
    property real notificationPopupWidth: 420
    property real hyprlandGapsOut: HyprlandData.hyprlandGapsOut
    property real elevationValue: Appearance.padding.verylarge
    property real frameThickness: Mem.options.desktop.bg.borderMultiplier * (hyprlandGapsOut - Appearance.padding.normal)
    property real elevationMargin: frameThickness + elevationValue
    property var aiBarSize: Qt.size(600,60)
}
