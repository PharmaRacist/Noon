import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.common
import qs.common.widgets
import qs.services

StyledPanel {
    id: panelRoot
    name: "osd"

    property real value
    property string icon
    property var targetScreen

    signal valueModified(real newValue)
    signal interactionStarted
    signal interactionEnded
    visible: true
    anchors.bottom: true

    mask: Region {
        item: nobuntu
    }

    implicitWidth: nobuntu.implicitWidth
    implicitHeight: nobuntu.implicitHeight + Sizes.elevationMargin * 2

    Connections {
        target: panelRoot
        function onTargetScreenChanged() {
            panelRoot.screen = panelRoot.targetScreen;
        }
    }

    StyledRect {
        id: nobuntu
        anchors.centerIn: parent

        implicitWidth: Sizes.osd.nobuntu.width
        implicitHeight: Sizes.osd.nobuntu.height
        enableBorders: true
        color: Colors.colLayer0
        radius: Rounding.full
        clip: true

        RowLayout {
            id: mainContent
            spacing: Padding.large
            anchors.fill: parent
            anchors.leftMargin: Padding.veryhuge
            anchors.rightMargin: Padding.huge

            Symbol {
                fill: 1
                color: Colors.colPrimary
                text: panelRoot.icon
                font.pixelSize: Fonts.sizes.huge
            }

            StyledProgressBar {
                id: valueProgressBar
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height / 2
                value: panelRoot.value
                valueBarGap: parent.height / 3
            }
        }
    }
}
