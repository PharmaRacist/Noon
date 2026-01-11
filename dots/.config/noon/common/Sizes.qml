pragma Singleton
import QtQuick
import Quickshell
import qs.common
import qs.services

Singleton {
    property real barElevation: hyprland.gapsOut / 2
    property real osdWidth: 220
    property real osdHeight: 45
    property real collapsedSideBarWidth: 50
    property real notificationPopupWidth: 420
    property real elevationValue: Padding.verylarge
    property real frameThickness: Mem.options.desktop.bg.borderMultiplier * (hyprland.gapsOut - Padding.normal)
    property real elevationMargin: Math.round(frameThickness + elevationValue)
    property size beamSize: Qt.size(450, 60)
    property size beamSizeExpanded: Qt.size(800, 100)
    property size gameLauncherItemSize: Qt.size(225, 360)
    property QtObject hyprland
    property QtObject sidebar
    property QtObject osd

    osd: QtObject {
        property size bottomPill: Qt.size(180, 42)
        property size centerIsland: Qt.size(145, 145)
        property size sideBay: Qt.size(48, 200)
        property size windows_10: Qt.size(85, 240)
    }

    sidebar: QtObject {
        property real bar: Sizes.collapsedSideBarWidth
        property real contentQuarter: Math.round(Screen.width * 0.235) - Sizes.collapsedSideBarWidth
        property real half: Math.round(Screen.width * 0.457)
        property real quarter: Math.round(Screen.width * 0.246)
        property real threeQuarter: Math.round(Screen.width * 0.85)
        property real session: 280
        property real overview: 1250
        property real widgetSize: 172
        property real widgetPillHeight: 72
        property size shelfItemSize: Qt.size(115, 115)
        property size shelfPopupSize: Qt.size(300, 200)

        property QtObject widgets: QtObject {
            property real expandedWidth: 2 * Sizes.sidebar.widgetSize + Padding.verylarge
        }
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
