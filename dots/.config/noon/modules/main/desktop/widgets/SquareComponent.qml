import QtQuick

import qs.common
import qs.common.widgets
import qs.common.functions

StyledRect {
    id: root
    property bool pinned: false
    property bool pill: false
    property bool expanded: false
    readonly property string bgMode: Mem.options.desktop.widgets.mode

    clip: true
    enableBorders: true
    implicitWidth: Sizes.sidebar.widgetSize
    implicitHeight: Sizes.sidebar.widgetSize
    radius: pill ? 99 : Rounding.verylarge
    color: bgMode === "col" ? Colors.colLayer1 : "transparent"

    Symbol {
        z: 999
        font.pixelSize: 20
        visible: pinned
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Padding.large
        opacity: 0.6
        color: Colors.colOnLayer0
        text: "push_pin"
        rotation: 45
    }

    gradient: Gradient {
        orientation: Gradient.Vertical

        GradientStop {
            position: 1
            color: manageColor(Colors.colLayer0, 0.1)
        }
        GradientStop {
            position: 0.75
            color: manageColor(Colors.colLayer1, 0.25)
        }
        GradientStop {
            position: 0
            color: manageColor(Colors.colOutlineVariant, 0.9)
        }
    }

    function manageColor(color, opacity) {
        if (bgMode === "grad")
            return ColorUtils.transparentize(color, opacity);
        else
            return Colors.colLayer0;
    }

    Behavior on radius {
        Anim {}
    }
}
