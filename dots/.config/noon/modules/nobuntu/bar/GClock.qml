import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.common
import qs.services
import "./../common"
import qs.common.widgets

Item {
    id: root
    anchors.centerIn: parent
    implicitWidth: 200
    implicitHeight: Math.round(parent.height * 0.75)

    StyledRect {
        anchors.fill: parent
        radius: Rounding.full
        color: {
            if (_event_area.containsMouse)
                Colors.colLayer0Hover;
            else if (_event_area.pressed)
                Colors.colLayer0Active;
            else
                "transparent";
        }
        StyledText {
            anchors.centerIn: parent
            color: Colors.colOnLayer0
            font {
                pixelSize: 16
                weight: Font.DemiBold
                family: "Roboto"
            }
            text: DateTimeService.gnome_format
        }
        MouseArea {
            id: _event_area
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            hoverEnabled: true
            onClicked: NoonUtils.callIpc("nobuntu toggle_notifs")
        }
    }
}
