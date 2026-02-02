import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets

StyledRect {
    id: root
    property bool vertical: vertical
    property bool verticalMode: false
    readonly property real padding: Padding.small

    color: Mem.options.bar.appearance.barGroup ? Colors.colLayer2 : "transparent"
    radius: Rounding.large
    clip: true
    Layout.fillHeight: !vertical
    Layout.fillWidth: vertical
    Layout.topMargin: if (!vertical)
        padding
    Layout.bottomMargin: if (!vertical)
        padding
    Layout.rightMargin: if (vertical)
        padding
    Layout.leftMargin: if (vertical)
        padding
}
