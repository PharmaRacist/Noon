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
    anchors.bottom: true

    mask: Region {
        item: bottomPill
    }

    implicitWidth: bottomPill.implicitWidth
    implicitHeight: bottomPill.implicitHeight + Sizes.elevationMargin * 2

    Connections {
        target: panelRoot
        function onTargetScreenChanged() {
            panelRoot.screen = panelRoot.targetScreen;
        }
    }

    StyledRect {
        id: bottomPill
        anchors.centerIn: parent

        implicitWidth: Sizes.osd.bottomPill.width
        implicitHeight: Sizes.osd.bottomPill.height
        color: Colors.colLayer0
        radius: Rounding.normal
        clip: true


        Rectangle {
            id: sideRect
            implicitWidth: 40
            color: Colors.colPrimary
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }

            ColumnLayout {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 2
                spacing: -2

                Symbol {
                    fill: 1
                    animateChange: true
                    color: Colors.colOnPrimary
                    text: panelRoot.icon
                    font.pixelSize: Fonts.sizes.huge
                }

                StyledText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    color: Colors.colOnPrimary
                    text: Math.round(panelRoot.value * 100)
                    font.variableAxes: Fonts.variableAxes.numbers
                    font.pixelSize: Fonts.sizes.small
                }
            }
        }

        RowLayout {
            id: mainContent
            spacing: Padding.normal
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: sideRect.right
                right: parent.right
                rightMargin: Padding.large
                leftMargin: Padding.large
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
