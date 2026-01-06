import QtQuick
import qs.common
import qs.common.widgets

StyledRect {
    property bool pill: false
    property bool expanded: false

    clip: true
    implicitWidth: Sizes.sidebar.widgetSize
    implicitHeight: Sizes.sidebar.widgetSize
    color: Colors.colLayer1
    radius: pill ? 99 : Rounding.verylarge
    enableBorders: true

    Behavior on radius {
        Anim {
        }

    }

}
