import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.common.widgets

IslamWidgetBase {
    id: root
    implicitHeight: content?.implicitHeight + Padding.massive
    expanded: true

    MouseArea {
        z: 999
        hoverEnabled: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: AzkarService.loadZekrForTime()
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
            text: AzkarService.currentZekr?.category || "ذِكر"
            Layout.topMargin: Padding.large
            Layout.preferredHeight: 25
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
            horizontalAlignment: Text.AlignRight
            text: AzkarService.currentZekr?.content || "..."
        }
    }
}
