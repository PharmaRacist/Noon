import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

BarGroup {
    id: root

    implicitHeight: columnLayout.implicitHeight

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
            model: [
                {
                    text: DateTimeService.hour
                },
                {
                    text: DateTimeService.minute
                },
                {
                    text: DateTimeService.dayTime,
                    visible: DateTimeService.dayTime !== ""
                },
            ]
            StyledText {
                required property var modelData
                text: modelData.text
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
