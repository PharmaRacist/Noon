import QtQuick
import Quickshell
import qs.common
import qs.services
pragma Singleton

Singleton {
    property real barElevation: hyprlandGapsOut / 4
    property real osdWidth: 220
    property real osdHeight: 45
    property real collapsedSideBarWidth: 50
    property real notificationPopupWidth: 420
    property real elevationValue: Padding.verylarge
    property real frameThickness: Mem.options.desktop.bg.borderMultiplier * (hyprland.gapsOut - Padding.normal)
    property real elevationMargin: frameThickness + elevationValue
    property size beamSize: Qt.size(450, 60)
    property size beamSizeExpanded: Qt.size(800, 100)
    property size gameLauncherItemSize: Qt.size(225, 360) // Expanded
    property QtObject hyprland
    property QtObject sidebar

    sidebar: QtObject {
        property real bar: Sizes.collapsedSideBarWidth
        property real contentQuarter: Math.round(Screen.width * 0.235) - Sizes.collapsedSideBarWidth
        property real half: Math.round(Screen.width * 0.457)
        property real quarter: Math.round(Screen.width * 0.246)
        property real threeQuarter: Math.round(Screen.width * 0.85)
        property real session: 280
        property real overview: 1250
    }

    hyprland: QtObject {
        property real borders: HyprlandParserService.get("borders") || 0
        property real gapsOut: HyprlandParserService.get("gaps_out") || 0
        property real gapsIn: HyprlandParserService.get("gaps_in") || 0
        property real blurSize: HyprlandParserService.get("blur_size") || 0
        property real blurPasses: HyprlandParserService.get("blur_passes") || 0
        property real shadowsRange: HyprlandParserService.get("shadows_range") || 0
    }

}
