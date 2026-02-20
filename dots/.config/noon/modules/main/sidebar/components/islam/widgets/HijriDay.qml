import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.common.widgets

IslamWidgetBase {
    id: root
    expanded: true
    implicitHeight: 55

    RowLayout {
        anchors.fill: parent
        anchors.margins: Padding.veryhuge
        StyledText {
            text: "Today is "
            Layout.fillWidth: true
            color: Colors.colOnLayer2
            horizontalAlignment: Text.AlignLeft
        }

        StyledText {
            text: PrayerService.prayerTimes.hijriDate
            color: Colors.colPrimary
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
