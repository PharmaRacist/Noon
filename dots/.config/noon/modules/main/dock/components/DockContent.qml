import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.common
import qs.common.widgets
import qs.modules.main.dock
import qs.services

Item {
    id: root
    property bool pinned
    implicitWidth: content.implicitWidth + (Padding.massive * Mem.options.dock.appearance.iconSizeMultiplier)
    implicitHeight: content.implicitHeight + (Padding.massive * Mem.options.dock.appearance.iconSizeMultiplier)
    property alias radius: rect.radius
    StyledRect {
        id: rect
        anchors.fill: parent
        color: Colors.colLayer0
        enableBorders: true

        RowLayout {
            id: content

            anchors.centerIn: parent

            DockApps {
                id: dockApps
            }
        }
    }
    StyledRectangularShadow {
        target: rect
    }
}
