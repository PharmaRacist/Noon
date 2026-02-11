import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common
import qs.store

Rectangle {
    color: Colors.colOutlineVariant
    implicitHeight: 1
    Layout.fillWidth: true
    Layout.leftMargin: Padding.large
    Layout.rightMargin: Padding.large
    Layout.margins: 4
    visible: Mem.options.bar.appearance.enableSeparators
}
