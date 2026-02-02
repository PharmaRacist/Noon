import QtQuick
import qs.common
import qs.store

Rectangle {
    color: Colors.colOutlineVariant
    visible: Mem?.options?.bar?.appearance?.enableSeparators ?? false
    implicitWidth: 1
    Layout.fillHeight: true
    Layout.topMargin: Padding.large
    Layout.bottomMargin: Padding.large
    Layout.margins: 4
}
