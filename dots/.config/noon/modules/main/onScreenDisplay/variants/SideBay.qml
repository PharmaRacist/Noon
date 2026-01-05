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
    visible:true
    anchors {
        right: true
    }

    mask: Region {
        item: content
    }

    implicitWidth: content.implicitWidth + Sizes.elevationMargin * 2
    implicitHeight: content.implicitHeight + Sizes.elevationMargin * 2

    Connections {
        target: panelRoot
        function onTargetScreenChanged() {
            panelRoot.screen = panelRoot.targetScreen;
        }
    }

    StyledRect {
        id: content
        anchors.centerIn: parent

        implicitWidth: Sizes.osd.sideBay.width
        implicitHeight: Sizes.osd.sideBay.height
        enableShadows: true
        color: Colors.colLayer0
        radius: Rounding.full
        clip: true

        ColumnLayout {
            id: mainContent
            spacing: Padding.normal
            anchors {
                fill: parent
                topMargin: Padding.large
                bottomMargin: Padding.large
                margins: Padding.normal
            }
            StyledProgressBar {
                id: valueProgressBar
                vertical: true
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                value: panelRoot.value
                valueBarGap: 24
            }
            StyledText {
                font {
                    family: Fonts.family.numbers
                    variableAxes: Fonts.variableAxes.numbers
                    pixelSize: 19
                }
                text: Math.round(panelRoot.value * 100)
                color: Colors.colSecondary
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
