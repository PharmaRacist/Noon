import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.common.widgets

IslamWidgetBase {
    id: root
    expanded: true
    implicitHeight: 525

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Padding.huge
        spacing: Padding.large

        StyledText {
            text: "Prayer Times"
            color: Colors.colOnLayer2
            Layout.leftMargin: Padding.large
            Layout.preferredHeight: 55
            font.pointSize: Fonts.sizes.verylarge
            font.variableAxes: Fonts.variableAxes.title
        }

        Separator {}

        StyledListView {
            id: list
            clip: true
            hint: false
            Layout.fillWidth: true
            model: PrayerService.prayerNames
            Layout.fillHeight: true

            delegate: StyledDelegateItem {
                toggled: modelData === PrayerService.nextPrayer
                width: list.width
                materialIcon: PrayerService.prayerIcons[modelData]
                title: modelData
                subtext: PrayerService.remainingTimes[modelData].formatted + " / " + PrayerService.prayerTimes[modelData.toLowerCase()]

                StyledCheckbox {
                    id: checkbox
                    z: 0
                    checked: PrayerService?.isPrayerDone(modelData) ?? false
                    onClicked: PrayerService?.togglePrayer(modelData, checked)
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: Padding.hu345ge
                    }
                }
            }
        }
    }
}
