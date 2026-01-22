import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.common
import qs.common.widgets
import qs.services

StyledText {
    font.family: "Rubik"
    font.pixelSize: Fonts.sizes.normal
    color: Colors.m3.m3onSurfaceVariant
    text: DateTimeService.gnomeClockWidgetFormat

    MouseArea {
        anchors.fill: parent
        onClicked: NoonUtils.callIpc("sidebar reveal Apps")
    }

}
