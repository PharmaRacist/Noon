import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services

StyledPopup {
    id: root

    ColumnLayout {
        id: columnLayout

        anchors.centerIn: parent
        spacing: 8

        // Header with location and dates
        Column {
            Layout.fillWidth: true
            spacing: 4

            Row {
                spacing: 6

                MaterialSymbol {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "mosque"
                    fill: 1
                    font.pixelSize: Fonts.sizes.large
                    color: Colors.m3.m3onSurfaceVariant
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    StyledText {
                        text: PrayerService.currentCity
                        color: Colors.m3.m3onSurfaceVariant

                        font {
                            weight: Font.Medium
                            pixelSize: Fonts.sizes.normal
                        }

                    }

                    StyledText {
                        text: PrayerService.prayerTimes.date
                        color: Colors.m3.m3onSurfaceVariant
                        opacity: 0.8

                        font {
                            pixelSize: Fonts.sizes.small
                        }

                    }

                }

            }

            StyledText {
                text: PrayerService.prayerTimes.hijriDate
                color: Colors.m3.m3onSurfaceVariant
                opacity: 0.7
                leftPadding: 6

                font {
                    pixelSize: Fonts.sizes.small
                }

            }

        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Colors.m3.m3onSurfaceVariant
            opacity: 0.2
        }

        // Next Prayer Highlight
        RowLayout {
            spacing: 5
            Layout.fillWidth: true
            visible: PrayerService.nextPrayer !== ""

            MaterialSymbol {
                text: "schedule"
                color: Colors.m3.m3primary
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: qsTr("Next Prayer:")
                color: Colors.m3.m3primary
                font.weight: Font.Medium
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: Colors.m3.m3primary
                text: PrayerService.nextPrayer + " in " + PrayerService.timeUntilNext
                font.weight: Font.Medium
            }

        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Colors.m3.m3onSurfaceVariant
            opacity: 0.2
            visible: PrayerService.nextPrayer !== ""
        }

        // Fajr
        RowLayout {
            spacing: 5
            Layout.fillWidth: true
            visible: PrayerService.prayerTimes.fajr !== ""

            MaterialSymbol {
                text: PrayerService.prayerIcons.Fajr
                color: PrayerService.nextPrayer === "Fajr" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: qsTr("Fajr:")
                color: PrayerService.nextPrayer === "Fajr" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                font.weight: PrayerService.nextPrayer === "Fajr" ? Font.Medium : Font.Normal
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: PrayerService.nextPrayer === "Fajr" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                text: PrayerService.prayerTimes.fajr
                font.weight: PrayerService.nextPrayer === "Fajr" ? Font.Medium : Font.Normal
            }

            StyledText {
                text: PrayerService.remainingTimes.Fajr.formatted
                color: Colors.m3.m3onSurfaceVariant
                opacity: 0.7
                font.pixelSize: Fonts.sizes.small
            }

        }

        // Sunrise
        RowLayout {
            spacing: 5
            Layout.fillWidth: true
            visible: PrayerService.prayerTimes.sunrise !== ""

            MaterialSymbol {
                text: PrayerService.prayerIcons.Sunrise
                color: PrayerService.nextPrayer === "Sunrise" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: qsTr("Sunrise:")
                color: PrayerService.nextPrayer === "Sunrise" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                font.weight: PrayerService.nextPrayer === "Sunrise" ? Font.Medium : Font.Normal
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: PrayerService.nextPrayer === "Sunrise" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                text: PrayerService.prayerTimes.sunrise
                font.weight: PrayerService.nextPrayer === "Sunrise" ? Font.Medium : Font.Normal
            }

            StyledText {
                text: PrayerService.remainingTimes.Sunrise.formatted
                color: Colors.m3.m3onSurfaceVariant
                opacity: 0.7
                font.pixelSize: Fonts.sizes.small
            }

        }

        // Dhuhr
        RowLayout {
            spacing: 5
            Layout.fillWidth: true
            visible: PrayerService.prayerTimes.dhuhr !== ""

            MaterialSymbol {
                text: PrayerService.prayerIcons.Dhuhr
                color: PrayerService.nextPrayer === "Dhuhr" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: qsTr("Dhuhr:")
                color: PrayerService.nextPrayer === "Dhuhr" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                font.weight: PrayerService.nextPrayer === "Dhuhr" ? Font.Medium : Font.Normal
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: PrayerService.nextPrayer === "Dhuhr" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                text: PrayerService.prayerTimes.dhuhr
                font.weight: PrayerService.nextPrayer === "Dhuhr" ? Font.Medium : Font.Normal
            }

            StyledText {
                text: PrayerService.remainingTimes.Dhuhr.formatted
                color: Colors.m3.m3onSurfaceVariant
                opacity: 0.7
                font.pixelSize: Fonts.sizes.small
            }

        }

        // Asr
        RowLayout {
            spacing: 5
            Layout.fillWidth: true
            visible: PrayerService.prayerTimes.asr !== ""

            MaterialSymbol {
                text: PrayerService.prayerIcons.Asr
                color: PrayerService.nextPrayer === "Asr" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: qsTr("Asr:")
                color: PrayerService.nextPrayer === "Asr" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                font.weight: PrayerService.nextPrayer === "Asr" ? Font.Medium : Font.Normal
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: PrayerService.nextPrayer === "Asr" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                text: PrayerService.prayerTimes.asr
                font.weight: PrayerService.nextPrayer === "Asr" ? Font.Medium : Font.Normal
            }

            StyledText {
                text: PrayerService.remainingTimes.Asr.formatted
                color: Colors.m3.m3onSurfaceVariant
                opacity: 0.7
                font.pixelSize: Fonts.sizes.small
            }

        }

        // Maghrib
        RowLayout {
            spacing: 5
            Layout.fillWidth: true
            visible: PrayerService.prayerTimes.maghrib !== ""

            MaterialSymbol {
                text: PrayerService.prayerIcons.Maghrib
                color: PrayerService.nextPrayer === "Maghrib" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: qsTr("Maghrib:")
                color: PrayerService.nextPrayer === "Maghrib" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                font.weight: PrayerService.nextPrayer === "Maghrib" ? Font.Medium : Font.Normal
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: PrayerService.nextPrayer === "Maghrib" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                text: PrayerService.prayerTimes.maghrib
                font.weight: PrayerService.nextPrayer === "Maghrib" ? Font.Medium : Font.Normal
            }

            StyledText {
                text: PrayerService.remainingTimes.Maghrib.formatted
                color: Colors.m3.m3onSurfaceVariant
                opacity: 0.7
                font.pixelSize: Fonts.sizes.small
            }

        }

        // Isha
        RowLayout {
            spacing: 5
            Layout.fillWidth: true
            visible: PrayerService.prayerTimes.isha !== ""

            MaterialSymbol {
                text: PrayerService.prayerIcons.Isha
                color: PrayerService.nextPrayer === "Isha" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: qsTr("Isha:")
                color: PrayerService.nextPrayer === "Isha" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                font.weight: PrayerService.nextPrayer === "Isha" ? Font.Medium : Font.Normal
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: PrayerService.nextPrayer === "Isha" ? Colors.m3.m3primary : Colors.m3.m3onSurfaceVariant
                text: PrayerService.prayerTimes.isha
                font.weight: PrayerService.nextPrayer === "Isha" ? Font.Medium : Font.Normal
            }

            StyledText {
                text: PrayerService.remainingTimes.Isha.formatted
                color: Colors.m3.m3onSurfaceVariant
                opacity: 0.7
                font.pixelSize: Fonts.sizes.small
            }

        }

    }

}
