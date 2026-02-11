import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

BarGroup {
    id: root

    implicitHeight: columnLayout.implicitHeight + (active ? Padding.massive : 0)

    MouseArea {
        id: event_area
        hoverEnabled: true
        anchors.fill: parent
    }

    ColumnLayout {
        id: columnLayout

        anchors.centerIn: parent
        spacing: Padding.tiny

        Repeater {
            model: [DateTimeService.hour, DateTimeService.minute, DateTimeService.dayTime]
            StyledText {
                required property var modelData
                visible: modelData !== ""
                text: modelData
                font.weight: 900
                font.family: Fonts.family.monospace
                font.pixelSize: Fonts.sizes.normal
                color: Colors.colSecondary
                Layout.alignment: Qt.AlignHCenter
                animateChange: true
            }
        }
    }

    PrayerPopup {
        hoverTarget: event_area
    }
}
