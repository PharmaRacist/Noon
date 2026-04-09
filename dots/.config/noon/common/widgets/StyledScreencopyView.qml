import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.common
import qs.common.utils
import qs.services

ScreencopyView {
    id: root
    paintCursor: false
    constraintSize: Qt.size(parent.width, parent.height)
    visible: HyprlandService.isHyprland
    live: true
}
