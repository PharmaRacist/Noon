import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common
import qs.common.widgets
import "./../common"

StyledPanel {
    id: root
    name: "notifs"
    shell: "nobuntu"
    visible: GlobalStates.nobuntu.notifs.show
    anchors {
        top: true
    }
    implicitHeight: 520
    implicitWidth: 800
    mask: Region {
        item: bg
    }
    HyprlandFocusGrab {
        windows: [root]
        active: root.visible
        onCleared: GlobalStates.nobuntu.notifs.show = false
    }
    StyledRect {
        id: bg
        anchors.topMargin: Padding.normal
        anchors.fill: parent
        radius: 40
        enableBorders: true
        color: Colors.colLayer0 //Colors.colLayer2
    }
}
