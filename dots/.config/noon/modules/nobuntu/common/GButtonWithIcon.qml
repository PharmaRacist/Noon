import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.common
import qs.common.widgets
import qs.services

GButton {
    property string iconSource
    property int iconSize: 22
    property int implicitSize: 45
    implicitWidth: implicitSize
    implicitHeight: implicitSize

    IconImage {
        source: NoonUtils.iconPath(iconSource)
        anchors.centerIn: parent
        implicitSize: iconSize
    }
}
