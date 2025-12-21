import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Item {
    // StyledRectangularShadow {
    //     target: cardBackground
    //     radius: Rounding.normal
    // }

    id: root

    property int timerId: -1
    property string timerName: ""
    property int originalDuration: 0
    property int remainingTime: 0
    property bool isRunning: false
    property bool isPaused: false
    property string timerIcon: "timer"
    // Calculate progress percentage automatically
    property real progressPercentage: {
        if (originalDuration <= 0)
            return 0;

        return ((originalDuration - remainingTime) / originalDuration);
    }

    signal startRequested()
    signal pauseRequested()
    signal resetRequested()
    signal removeRequested()

    function formatTime(seconds) {
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        const secs = seconds % 60;
        if (hours > 0)
            return hours + ":" + (minutes < 10 ? "0" : "") + minutes + ":" + (secs < 10 ? "0" : "") + secs;
        else
            return minutes + ":" + (secs < 10 ? "0" : "") + secs;
    }

    height: 95
    // Add this to monitor progress changes (for debugging)
    onProgressPercentageChanged: {
        console.log("Progress:", progressPercentage, "Original:", originalDuration, "Remaining:", remainingTime);
    }

    Rectangle {
        id: cardBackground

        anchors.fill: parent
        radius: Rounding.normal
        color: Colors.colLayer1

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 10
            anchors.rightMargin: 16
            anchors.leftMargin: 16
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                // Timer icon and info
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        spacing: 8

                        Rectangle {
                            Layout.leftMargin: 5
                            radius: Rounding.small
                            color: Colors.m3.m3primaryContainer
                            implicitHeight: 38
                            implicitWidth: 38

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: root.timerIcon
                                fill: 1
                                font.pixelSize: parent.height * 0.7
                                color: Colors.m3.m3onPrimaryContainer
                            }

                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            StyledText {
                                Layout.fillWidth: true
                                text: root.timerName
                                color: Colors.colOnLayer0
                                font.pixelSize: Fonts.sizes.normal
                                elide: Text.ElideRight // Truncates the text on the right
                                width: 100
                            }

                            StyledText {
                                text: root.formatTime(root.remainingTime)
                                color: Colors.colSubtext
                                font.pixelSize: Fonts.sizes.small
                            }

                        }

                    }

                }

                // Control buttons
                RowLayout {
                    spacing: 4

                    // Play/Pause button
                    Button {
                        id: playPauseButton

                        width: enabled ? 70 : 35
                        height: 35
                        enabled: root.remainingTime > 0
                        onClicked: {
                            if (root.isRunning)
                                root.pauseRequested();
                            else
                                root.startRequested();
                        }

                        PointingHandInteraction {
                        }

                        background: BouncyShapeBackground {
                            anchors.fill: parent
                            anchors.margins: 3
                            backgroundRadius: root.isRunning ? 12 : 99
                            backgroundColor: !playPauseButton.enabled ? Colors.m3.m3surfaceContainerHighest : playPauseButton.down ? Qt.darker(Colors.m3.m3primary, 1.2) : playPauseButton.hovered ? Qt.lighter(Colors.m3.m3primary, 1.2) : Colors.m3.m3primary
                            backgroundOpacity: playPauseButton.enabled ? 1 : 0.3
                        }

                        contentItem: MaterialSymbol {
                            text: root.isRunning ? "pause" : "play_arrow"
                            font.pixelSize: 16
                            fill: 1
                            color: playPauseButton.enabled ? Colors.m3.m3secondaryContainer : Colors.m3.m3outline
                            anchors.centerIn: parent
                        }

                    }

                    // Reset button
                    Button {
                        id: resetButton

                        width: 25
                        height: 25
                        enabled: root.remainingTime !== root.originalDuration
                        onClicked: root.resetRequested()

                        PointingHandInteraction {
                        }

                        background: Rectangle {
                            anchors.fill: parent
                            radius: 20
                            color: {
                                if (!resetButton.enabled)
                                    return Colors.m3.m3surfaceContainer;

                                if (resetButton.down)
                                    return Colors.m3.m3surfaceContainerHigh;

                                if (resetButton.hovered)
                                    return Colors.m3.m3surfaceContainer;

                                return Colors.m3.m3surfaceContainerLow;
                            }

                            Behavior on color {
                                CAnim {}
                            }

                        }

                        contentItem: MaterialSymbol {
                            text: "refresh"
                            fill: 1
                            font.pixelSize: 16
                            color: resetButton.enabled ? Colors.m3.m3onSurface : Colors.m3.m3outline
                            anchors.centerIn: parent
                        }

                    }

                    // Remove button
                    Button {
                        id: removeButton

                        width: 25
                        height: 25
                        onClicked: root.removeRequested()

                        PointingHandInteraction {
                        }

                        background: Rectangle {
                            anchors.fill: parent
                            radius: 20
                            color: {
                                if (removeButton.down)
                                    return Colors.m3.m3errorContainer;

                                if (removeButton.hovered)
                                    return Qt.lighter(Colors.m3.m3errorContainer, 1.5);

                                return Colors.m3.m3surfaceContainer;
                            }

                            Behavior on color {
                                CAnim {}
                            }

                        }

                        contentItem: MaterialSymbol {
                            text: "delete"
                            fill: 1
                            font.pixelSize: 16
                            color: removeButton.hovered ? Colors.m3.m3error : Colors.m3.m3onSurfaceVariant
                            anchors.centerIn: parent
                        }

                    }

                }

            }
            // Progress bar using StyledProgressBar

            StyledProgressBar {
                id: progressBar

                sperm: true
                Layout.fillWidth: true
                Layout.bottomMargin: 16
                valueBarHeight: 10
                // Fix: Use the calculated progress percentage directly (0-1 range)
                value: root.progressPercentage / 10011
                highlightColor: Colors.m3.m3primary
                trackColor: Colors.colLayer2Hover
            }

        }

    }

}
