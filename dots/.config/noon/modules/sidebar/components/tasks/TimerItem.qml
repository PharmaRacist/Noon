import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

Rectangle {
    id: timerDock

    property int contentWidth: timerContent.implicitWidth + 36
    property bool extraVisibleCondition

    function requestOverlayMode() {
        Mem.options.desktop.timerOverlayMode = !Mem.options.desktop.timerOverlayMode;
    }

    // Auto-hide when no timers
    visible: TimerService.timers.length >= 1 && extraVisibleCondition
    width: visible ? contentWidth : 0
    height: 55
    border.color: Colors.colOutline
    color: Colors.m3.m3secondaryContainer
    topLeftRadius: Rounding.verylarge
    topRightRadius: Rounding.verylarge
    bottomRightRadius: Rounding.verylarge
    bottomLeftRadius: Rounding.verylarge

    RowLayout {
        id: timerContent

        anchors.centerIn: parent

        Repeater {
            model: TimerService.timers

            delegate: RowLayout {
                spacing: 0

                Rectangle {
                    color: "transparent"
                    implicitWidth: timerLayout.implicitWidth
                    implicitHeight: timerLayout.implicitHeight

                    RowLayout {
                        id: timerLayout

                        spacing: 12

                        // Timer info column
                        Column {
                            spacing: 2
                            Layout.alignment: Qt.AlignLeft

                            // Timer name
                            StyledText {
                                text: modelData.name
                                font.pixelSize: Fonts.sizes.small
                                color: Colors.m3.m3onSurface
                                opacity: 0.9
                                font.weight: 500
                            }

                            StyledText {
                                text: TimerService.formatTime(modelData.remainingTime)
                                font.pixelSize: Fonts.sizes.small
                                color: Colors.colOnLayer0
                                opacity: 0.7
                                font.weight: Font.DemiBold
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        CircularProgress {
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            lineWidth: 4
                            value: (modelData.originalDuration - modelData.remainingTime) / modelData.originalDuration
                            size: 40
                            secondaryColor: Colors.m3.m3secondaryContainer
                            primaryColor: modelData.color || Colors.m3.m3secondary

                            MaterialSymbol {
                                anchors.centerIn: parent
                                fill: 1
                                text: (modelData.isRunning ? "pause" : "play_arrow") ?? "timer"
                                font.pixelSize: Fonts.sizes.large
                                color: Colors.m3.m3onSecondaryContainer
                            }

                            // Smooth progress animation to reduce flickering
                            Behavior on value {
                                Anim {}
                            }
                        }
                    }

                    // Individual timer click area for pause/resume/delete
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                timerDock.requestOverlayMode();
                            } else if (mouse.button === Qt.MiddleButton) {
                                TimerService.removeTimer(modelData.id);
                            } else if (mouse.button === Qt.LeftButton) {
                                if (modelData.isRunning)
                                    TimerService.pauseTimer(modelData.id);
                                else if (modelData.isPaused)
                                    TimerService.startTimer(modelData.id);
                            }
                        }
                    }
                }

                // Separator - only show if not the last item
                Rectangle {
                    visible: index < TimerService.timers.length - 1
                    Layout.fillHeight: true
                    width: 1
                    color: Colors.colSubtext
                    opacity: 0.6
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                }
            }
        }
    }

    // Pulsing animation when any timer is about to finish (last 10 seconds)
    SequentialAnimation {
        running: {
            for (let i = 0; i < TimerService.timers.length; i++) {
                if (TimerService.timers[i].isRunning && TimerService.timers[i].remainingTime <= 10 && TimerService.timers[i].remainingTime > 0)
                    return true;
            }
            return false;
        }
        loops: Animation.Infinite

        Anim {
            target: timerDock
            property: "opacity"
            from: 1
            to: 0.6
        }

        Anim {
            target: timerDock
            property: "opacity"
            from: 0.6
            to: 1
        }
    }

    // Optional: Click handler for the dock background (if clicking outside individual timers)
    MouseArea {
        anchors.fill: parent
        z: -1 // Behind the timer elements
        hoverEnabled: true
        onClicked: {
            timerDock.requestOverlayMode();
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 300
        }
    }

    // Smooth width animation
    Behavior on width {
        Anim {}
    }
}
