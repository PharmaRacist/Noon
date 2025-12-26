import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common
import qs.store

Rectangle {
    color: Colors.colOutlineVariant
    implicitHeight: 1
    implicitWidth: BarData.currentBarExclusiveSize * BarData.barPadding
    Layout.margins: 4
}
