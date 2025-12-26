import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services
import qs.store

Item {
    id: root

    property var activeTimers: TimerService.uiTimers.filter((timer) => {
        return timer.isRunning || timer.isPaused;
    })
    property int contentWidth: Math.max(timerDock.width + activeTimers.length * timerDock.width, implicitHeight)

    function requestOverlayMode() {
        Mem.options.desktop.timerOverlayMode = !Mem.options.desktop.timerOverlayMode;
    }

    Layout.alignment: Qt.AlignLeft
    visible: activeTimers.length > 0
    implicitHeight: bg.implicitHeight
    width: contentWidth

    Rectangle {
        id: timerDock

        implicitHeight: parent.implicitHeight
        width: Math.max(implicitHeight, timerContent.implicitWidth + Padding.veryhuge)
        anchors.left: parent.left
        color: Colors.colLayer0
        radius: dockRoot.mainRounding
        border.color: bg.border.color
        clip: true

        StyledRectangularShadow {
            target: timerDock
            radius: timerDock.radius
        }

        RowLayout {
            id: timerContent

            anchors.centerIn: parent
            spacing: Padding.verylarge

            Repeater {
                model: root.activeTimers

                delegate: Item {
                    id: timerItem

                    property bool hovered: false

                    // Full size container - no animation here
                    implicitWidth: timerLayout.implicitWidth
                    implicitHeight: circProg.size

                    Rectangle {
                        id: timerRect

                        implicitHeight: parent.implicitHeight
                        // Animate the inner rectangle width
                        width: parent.width
                        anchors.right: parent.right
                        color: "transparent"
                        clip: true

                        RowLayout {
                            id: timerLayout

                            spacing: Padding.normal
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            CircularProgress {
                                id: circProg

                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                lineWidth: 4
                                value: (modelData.originalDuration - modelData.remainingTime) / modelData.originalDuration
                                size: 45
                                secondaryColor: "transparent"
                                primaryColor: modelData.color || Colors.m3.m3secondary

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    fill: 1
                                    text: modelData.isRunning ? "pause" : "play_arrow"
                                    font.pixelSize: Fonts.sizes.large
                                    color: Colors.m3.m3onSecondaryContainer
                                }

                            }

                            Revealer {
                                id: revealer

                                Layout.leftMargin: Padding.normal
                                reveal: mouse.containsMouse

                                ColumnLayout {
                                    visible: parent.reveal
                                    spacing: 0

                                    StyledText {
                                        color: Colors.colOnLayer1
                                        text: modelData.name
                                        font.pixelSize: Fonts.sizes.normal
                                        font.weight: Font.Medium
                                    }

                                    StyledText {
                                        color: Colors.colSubtext
                                        text: TimerService.formatTime(modelData.remainingTime) + " remaining"
                                        font.pixelSize: Fonts.sizes.small
                                    }

                                }

                            }

                        }

                        MouseArea {
                            id: mouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                            onClicked: (mouse) => {
                                if (mouse.button === Qt.RightButton) {
                                    root.requestOverlayMode();
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

                    Rectangle {
                        visible: index < root.activeTimers.length - 1
                        anchors.top: parent.top
                        anchors.bottom: parent
                        anchors.left: timerRect.right
                        anchors.margins: Padding.normal
                        anchors.verticalCenter: parent.verticalCenter
                        width: 2
                        color: Colors.colOutline
                    }

                }

            }

        }

    }

}
