import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.common.widgets

IslamWidgetBase {
    id: root
    visible: PrayerService.getFastingProgress() > 0
    expanded: true
    implicitHeight: 60

    RLayout {
        anchors.fill: parent
        anchors.margins: Padding.large
        spacing: Padding.huge
        ColumnLayout {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.preferredWidth: 100
            Layout.leftMargin: Padding.large
            StyledText {
                text: "Fasting Progress"
                font {
                    pixelSize: Fonts.sizes.small
                    variableAxes: Fonts.variableAxes.title
                }
                color: Colors.colPrimary
            }
            StyledText {
                font {
                    pixelSize: Fonts.sizes.small
                    weight: Font.Bold
                }
                color: Colors.colSubtext
                text: PrayerService.remainingTimes["Maghrib"].formatted
            }
        }
        StyledProgressBar {
            Layout.fillWidth: true
            Layout.preferredHeight: 16
            valueBarHeight: 4
            sperm: true
            value: PrayerService.getFastingProgress()
        }
    }
}
