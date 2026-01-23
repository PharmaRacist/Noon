import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.common
import qs.common.widgets
import qs.modules.main.bar.components
import qs.services
import qs.store

BarGroup {
    id: root
    vertical: true

    implicitHeight: columnLayout.height + Padding.huge
    MouseArea {
        id: event_area
        hoverEnabled: true
    }
    ColumnLayout {
        id: columnLayout

        anchors.centerIn: parent
        spacing: 6

        StyledText {
            font.pixelSize: Fonts.sizes.small
            color: Colors.colOnLayer1
            text: DateTimeService.hour
            font.variableAxes: Fonts.variableAxes.title
            Layout.alignment: Qt.AlignHCenter
        }

        StyledText {
            font.pixelSize: Fonts.sizes.small
            font.variableAxes: Fonts.variableAxes.title
            color: Colors.colOnLayer1
            text: DateTimeService.minute
            Layout.alignment: Qt.AlignHCenter
        }

        // Add AM/PM indicator for 12-hour format
        StyledText {
            font.pixelSize: Fonts.sizes.small
            font.variableAxes: Fonts.variableAxes.title
            color: Colors.colOnLayer1
            text: DateTimeService.dayTime
            Layout.alignment: Qt.AlignHCenter
            visible: DateTimeService.dayTime !== "" // Only show if 12-hour format is enabled
        }
    }

    PrayerPopup {
        hoverTarget: event_area
    }
}
