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
    name: "fade_layer"

    property real value
    property string icon
    property var targetScreen

    signal valueModified(real newValue)
    signal interactionStarted
    signal interactionEnded

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

        implicitWidth: Sizes.osd.centerIsland.width
        implicitHeight: Sizes.osd.centerIsland.height
        enableShadows: true
        enableBorders: true
        color: Colors.colLayer0
        radius: Rounding.massive

        CircularProgress {
            id: circularProgress
            anchors.centerIn: parent
            value: panelRoot.value
            size: bottomPill.implicitWidth / 1.25
            lineWidth: 10

            property bool valueChanging: true

            Timer {
                id: valueChangeTimer
                interval: 1000
                onTriggered: circularProgress.valueChanging = false
            }

            Connections {
                target: panelRoot
                function onValueChanged() {
                    circularProgress.valueChanging = true;
                    valueChangeTimer.restart();
                }
            }

            MaterialSymbol {
                fill: 1
                animateChange: !circularProgress.valueChanging
                font {
                    family: circularProgress.valueChanging ? Fonts.family.numbers : Fonts.family.iconMaterial
                    variableAxes: circularProgress.valueChanging ? Fonts.variableAxes.numbers : variableAxes
                    pixelSize: bottomPill.implicitWidth / 3.85
                }
                text: circularProgress.valueChanging ? Math.round(panelRoot.value * 100) : panelRoot.icon
                color: Colors.colOnLayer0
                anchors.centerIn: parent
            }
        }
    }
}
