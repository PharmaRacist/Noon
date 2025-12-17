import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects

/**
 * Material 3 progress bar. See https://m3.material.io/components/progress-indicators/overview
 */
ProgressBar {
    id: root
    property real valueBarWidth: 120
    property real valueBarHeight: 4
    property real valueBarGap: 8
    property color highlightColor: Colors.colPrimary ?? "#685496"
    property color trackColor: Colors.m3.m3secondaryContainer ?? "#F1D3F9"
    property bool sperm: false // If true, the progress bar will have a wavy fill effect
    property bool animateSperm: true
    property real spermAmplitudeMultiplier: sperm ? 0.5 : 0
    property real spermFrequency: 6
    property real spermFps: 45
    property bool vertical: false // If true, progress bar grows vertically to the top

    Behavior on spermAmplitudeMultiplier {
        FAnim {}
    }
    Behavior on value {
        FAnim {}
    }

    background: Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: Rounding.full
        implicitHeight: vertical ? valueBarWidth : valueBarHeight
        implicitWidth: vertical ? valueBarHeight : valueBarWidth
    }

    contentItem: Item {
        anchors.fill: parent

        Canvas {
            id: wavyFill
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: vertical ? undefined : parent.verticalCenter
                top: vertical ? parent.top : undefined
                bottom: vertical ? parent.bottom : undefined
            }
            height: vertical ? parent.height : parent.height * 6
            width: vertical ? parent.width * 6 : parent.width

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                var progress = root.visualPosition;

                if (vertical) {
                    // Vertical mode - draw from bottom to top
                    var fillHeight = progress * parent.height;
                    var amplitude = parent.width * root.spermAmplitudeMultiplier;
                    var frequency = root.spermFrequency;
                    var phase = Date.now() / 400.0;
                    var centerX = width / 2;

                    ctx.strokeStyle = root.highlightColor;
                    ctx.lineWidth = parent.width;
                    ctx.lineCap = "round";
                    ctx.beginPath();

                    for (var y = parent.height - ctx.lineWidth / 2; y >= parent.height - fillHeight; y -= 1) {
                        var waveX = centerX + amplitude * Math.sin(frequency * 2 * Math.PI * (parent.height - y) / parent.height + phase);
                        if (y === parent.height - ctx.lineWidth / 2)
                            ctx.moveTo(waveX, y);
                        else
                            ctx.lineTo(waveX, y);
                    }
                    ctx.stroke();
                } else {
                    // Original horizontal mode - unchanged
                    var fillWidth = progress * width;
                    var amplitude = parent.height * root.spermAmplitudeMultiplier;
                    var frequency = root.spermFrequency;
                    var phase = Date.now() / 400.0;
                    var centerY = height / 2;
                    ctx.strokeStyle = root.highlightColor;
                    ctx.lineWidth = parent.height;
                    ctx.lineCap = "round";
                    ctx.beginPath();
                    for (var x = ctx.lineWidth / 2; x <= fillWidth; x += 1) {
                        var waveY = centerY + amplitude * Math.sin(frequency * 2 * Math.PI * x / width + phase);
                        if (x === 0)
                            ctx.moveTo(x, waveY);
                        else
                            ctx.lineTo(x, waveY);
                    }
                    ctx.stroke();
                }
            }

            Connections {
                target: root
                function onValueChanged() {
                    wavyFill.requestPaint();
                }
                function onHighlightColorChanged() {
                    wavyFill.requestPaint();
                }
                function onVerticalChanged() {
                    wavyFill.requestPaint();
                }
            }

            Timer {
                interval: 1000 / root.spermFps
                running: root.animateSperm
                repeat: root.sperm
                onTriggered: wavyFill.requestPaint()
            }
        }

        Rectangle {
            // Right remaining part fill (horizontal) / Top remaining part fill (vertical)
            radius: Rounding.full ?? 9999
            color: root.trackColor
            visible: !vertical
            anchors.right: parent.right
            width: (1 - root.visualPosition) * parent.width - valueBarGap
            height: parent.height
        }

        Rectangle {
            // Top remaining part fill (vertical mode only)
            radius: Rounding.full ?? 9999
            color: root.trackColor
            visible: vertical
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            width: parent.width
            height: (1 - root.visualPosition) * parent.height - valueBarGap
        }

        Rectangle {
            // Stop point (horizontal mode)
            anchors.right: vertical ? undefined : parent.right
            anchors.verticalCenter: vertical ? undefined : parent.verticalCenter
            anchors.rightMargin: vertical ? 0 : 6
            anchors.horizontalCenter: vertical ? parent.horizontalCenter : undefined
            anchors.top: vertical ? parent.top : undefined
            anchors.topMargin: vertical ? 6 : 0
            width: valueBarHeight / 1.5
            height: width
            radius: Rounding.full ?? 9999
            color: root.highlightColor
        }
    }
}
