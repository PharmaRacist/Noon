import QtQuick
import Quickshell
import qs.common
import qs.common.widgets
import qs.services
import "../clockVariants"

Loader {
    id: root
    z: 999

    readonly property Component verticalVariant: VDesktopClock {}
    readonly property Component normalVariant: DesktopClock {}

    readonly property bool isCentered: Mem.states.desktop.clock.center
    readonly property bool isVertical: Mem.options.desktop.clock.verticalMode

    anchors {
        centerIn: isCentered ? parent : undefined
        left: isCentered ? undefined : parent.left
        bottom: isCentered ? undefined : parent.bottom
        leftMargin: (Mem.options.bar.behavior.position === "left" ? Mem.options.bar.appearance.width + Sizes.elevationMargin : 0) + Sizes.hyprland.gapsOut
        bottomMargin: Math.max(Sizes.elevationMargin, Sizes.hyprland.gapsOut) + (Mem.options.bar.behavior.position === "bottom" ? Mem.options.bar.appearance.height : 0)
    }
    Behavior on anchors.leftMargin {
        Anim {}
    }
    Behavior on anchors.bottomMargin {
        Anim {}
    }
    sourceComponent: isVertical ? verticalVariant : normalVariant
}
