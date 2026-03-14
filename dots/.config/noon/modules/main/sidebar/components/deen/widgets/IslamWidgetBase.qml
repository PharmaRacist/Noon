import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets

StyledRect {
    property bool expanded: false
    enableBorders: true
    color: Colors.colLayer2
    radius: Rounding.large
    Layout.fillWidth: expanded
}
