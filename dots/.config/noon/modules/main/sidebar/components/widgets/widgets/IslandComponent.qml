import QtQuick
import qs.common
import qs.common.widgets

StyledRect {
    clip: true
    property bool pill: false
    property bool expanded: false
    implicitWidth: implicitSize
    implicitSize: Sizes.sidebar.widgetSize
    color: Colors.colLayer1
    radius: pill ? 99 : Rounding.verylarge
    enableShadows: true
    enableBorders: true
    Behavior on radius {
        Anim {}
    }
}
