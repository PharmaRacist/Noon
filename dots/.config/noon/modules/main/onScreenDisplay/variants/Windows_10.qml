import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

StyledPanel {
    id: panelRoot
    name: "fade_layer"

    property real value
    property string icon
    property var targetScreen

    signal valueModified(real newValue)
    signal interactionStarted
    signal interactionEnded
    visible:true
    anchors {
        top: true
        left: true
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

        implicitWidth: Sizes.osd.windows_10.width
        implicitHeight: Sizes.osd.windows_10.height
        enableShadows: true
        color: Colors.colLayer0
        radius: 0

        ColumnLayout {
            id: mainContent
            spacing: Padding.normal
            anchors {
                fill: parent
                topMargin: Padding.verylarge
                bottomMargin: Padding.verylarge
                margins: Padding.normal
            }
            StyledProgressBar {
                id: valueProgressBar
                vertical: true
                rounding: 0
                background: null
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: 14
                Layout.fillHeight: true
                value: panelRoot.value
                valueBarGap: parent.height
                showDot: false
            }
            StyledText {
                font {
                    family: Fonts.family.numbers
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
