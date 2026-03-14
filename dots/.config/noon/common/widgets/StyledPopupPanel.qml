import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.common
import qs.services
import qs.common.widgets

PopupWindow {
    id: root
    required property var panel
    required property var contentItem
    visible: true
    color: "transparent"
    implicitWidth: contentItem.implicitWidth + Padding.massive * 3
    implicitHeight: contentItem.implicitHeight + Padding.massive * 3
    FocusHandler {
        windows: [panel]
        onCleared: root.visible = false
        active: visible
    }
    anchor {
        window: panel
        adjustment: PopupAdjustment.None
        gravity: Edges.Top | Edges.Right
        edges: Edges.Top | Edges.right
        rect {
            x: panel.width + width + Padding.massive
            y: panel.height + Padding.massive
        }
    }
}
