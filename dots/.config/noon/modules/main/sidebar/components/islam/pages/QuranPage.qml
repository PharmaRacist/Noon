import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services
import qs.common
import qs.common.widgets

Item {
    id: root
    signal backRequested

    RippleButtonWithIcon {
        anchors {
            left: parent.left
            top: parent.top
            margins: Padding.huge
            topMargin: Padding.massive
        }
        materialIcon: "arrow_back"
        implicitSize: 48
        colBackground: "transparent"
        releaseAction: () => backRequested()
    }

    ColumnLayout {
        anchors.fill: parent

        StyledText {
            Layout.topMargin: Padding.large
            Layout.preferredHeight: 66
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            font {
                family: Fonts.family.quran
                weight: Font.Bold
                pixelSize: Fonts.sizes.huge
            }
            text: QuranService.currentSurah.name || "loading"
            color: Colors.colOnLayer1
        }

        StyledFlickable {
            Layout.topMargin: Padding.massive
            Layout.fillHeight: true
            Layout.fillWidth: true
            contentHeight: longText.height

            StyledText {
                id: longText
                width: parent.width - Padding.massive
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                lineHeight: 1.1
                text: QuranService.currentSurah.ayahs.map((a, i) => {
                    return a.text.trim() + " ﴿" + a.numberInSurah + "﴾";
                }).join(" ")

                font {
                    family: Fonts.family.quran
                    pixelSize: 28
                    weight: Font.DemiBold
                }
            }
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }
    }
}
