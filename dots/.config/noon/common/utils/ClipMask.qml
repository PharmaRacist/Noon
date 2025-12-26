import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.common
import qs.common.widgets
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

OpacityMask {
    id: root
    property alias radius: rect.radius

    maskSource: Rectangle {
        id: rect
        parent: root
        width: parent?.width
        height: parent?.height
        radius: parent?.radius
    }
}
