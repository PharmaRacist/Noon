import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.common.widgets

IslamWidgetBase {
    id: root
    implicitHeight: content?.implicitHeight
    expanded: true
    MouseArea {
        z: 999
        hoverEnabled: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: QuranService.getSurahByName(QuranService?.todaysAyah?.surah.englishName)
    }
    ColumnLayout {
        id: content
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Padding.huge
        anchors.rightMargin: Padding.huge
        spacing: Padding.large

        StyledText {
            font {
                pixelSize: Fonts.sizes.large
                family: Fonts.family.quran
            }
            leftPadding: Padding.large
            color: Colors.colOnLayer2
            text: "Today's Ayah "
            Layout.topMargin: Padding.large
            Layout.preferredHeight: 30
        }

        StyledText {
            font {
                pixelSize: Fonts.sizes.large
                family: Fonts.family.quran
                weight: Font.Bold
            }
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            leftPadding: Padding.large
            color: Colors.colOnLayer2
            text: QuranService?.todaysAyah?.text || "Loading..."
        }
    }
}
