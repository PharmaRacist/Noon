import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import qs.common
import qs.common.widgets
import qs.services
import "../common"

StyledPanel {
    id: root
    implicitWidth: 500
    name: "db"
    shell: "nobuntu"

    anchors {
        top: true
        right: true
        bottom: true
    }
    visible: GlobalStates.nobuntu.db.show
    mask: Region {
        item: bg
    }
    HyprlandFocusGrab {
        windows: [root]
        active: root.visible
        onCleared: GlobalStates.nobuntu.db.show = false
    }

    StyledRect {
        id: bg
        color: Colors.colLayer3
        radius: 34
        implicitWidth: 435
        implicitHeight: 290
        enableBorders: true
        anchors {
            top: parent.top
            right: parent.right
            margins: Padding.normal
        }
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Padding.verylarge
            TopRow {
            }
            // GBrightnessSlider {}
            // BottomRow {}
            Spacer {}
        }
    }
    StyledRectangularShadow {
        target: bg
    }
}
