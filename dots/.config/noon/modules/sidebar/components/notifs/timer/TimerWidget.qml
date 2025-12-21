import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Item {
    id: root

    property int currentTab: 0
    property bool showAddDialog: false
    property bool showCustomDialog: false
    property int dialogMargins: 20
    property int fabSize: 48
    property int fabMargins: 14

    // Timer service connection
    Connections {
        // Show notification or handle timer completion
        // console.log("Timer finished:", name);
        // Could trigger system notification here

        function onTimerFinished(timerId, name) {
        }

        target: Timer
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        SwipeView {
            id: swipeView

            Layout.topMargin: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            clip: true
            currentIndex: currentTab

            Loader {
                active: currentTab === 0

                sourceComponent: TimerList {
                    listBottomPadding: 0
                    emptyPlaceholderIcon: "timer"
                    timerList: TimerService.uiTimers
                    onStartTimer: timerId => {
                        return TimerService.startTimer(timerId);
                    }
                    onPauseTimer: timerId => {
                        return TimerService.pauseTimer(timerId);
                    }
                    onResetTimer: timerId => {
                        return TimerService.resetTimer(timerId);
                    }
                    onRemoveTimer: timerId => {
                        return TimerService.removeTimer(timerId);
                    }

                    MaterialSymbol {
                        anchors.centerIn: parent
                        opacity: TimerService.uiTimers.length !== 0 ? 0 : 0.25
                        text: "timer_off"
                        font.pixelSize: 180
                        color: Colors.m3.m3secondaryContainer

                        Behavior on opacity {
                            FAnim {}
                        }
                    }
                }
            }

            PresetList {
                listBottomPadding: 0
                emptyPlaceholderIcon: "apps"
                emptyPlaceholderText: qsTr("Timer presets")
                presetList: TimerService.presets
                onCreateFromPreset: preset => {
                    TimerService.addTimer(preset.name, preset.duration, preset);
                    root.currentTab = 0; // Switch to active timers
                }
            }
        }
    }

    // + FAB
    StyledRectangularShadow {
        target: fabButton
        radius: Rounding.normal
    }

    Button {
        id: fabButton

        z: 100
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: root.fabMargins
        anchors.bottomMargin: root.fabMargins
        width: root.fabSize
        height: root.fabSize
        onClicked: root.showAddDialog = true

        PointingHandInteraction {}

        background: Rectangle {
            id: fabBackground

            anchors.fill: parent
            radius: Rounding.normal
            color: (fabButton.down) ? Colors.colPrimaryContainerActive : (fabButton.hovered ? Colors.colPrimaryContainerHover : Colors.colPrimaryContainer)

            Behavior on color {
                CAnim {}
            }
        }

        contentItem: MaterialSymbol {
            text: "add"
            font.pixelSize: 32
            anchors.centerIn: fabBackground.center
            color: Colors.m3.m3onPrimaryContainer
        }
    }

    // Add Timer Dialog
    Item {
        anchors.fill: parent
        z: 9999
        visible: opacity > 0
        opacity: root.showAddDialog ? 1 : 0
        onVisibleChanged: {
            if (!visible) {
                timerNameInput.text = "";
                timerMinutesInput.text = "";
                timerSecondsInput.text = "";
                fabButton.focus = true;
            }
        }

        Rectangle {
            // Scrim
            anchors.fill: parent
            radius: Rounding.small
            color: Colors.colScrim

            MouseArea {
                hoverEnabled: true
                anchors.fill: parent
                preventStealing: true
                propagateComposedEvents: false
            }
        }

        // The dialog
        Rectangle {
            id: addDialog

            function addCustomTimer() {
                const minutes = parseInt(timerMinutesInput.text) || 0;
                const seconds = parseInt(timerSecondsInput.text) || 0;
                const totalSeconds = minutes * 60 + seconds;
                const name = timerNameInput.text || qsTr("Custom Timer");
                if (totalSeconds > 0) {
                    TimerService.addTimer(name, totalSeconds, null);
                    timerNameInput.text = "";
                    timerMinutesInput.text = "";
                    timerSecondsInput.text = "";
                    root.showAddDialog = false;
                    root.currentTab = 0; // Show active timers
                }
            }

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: root.dialogMargins
            implicitHeight: addDialogColumnLayout.implicitHeight
            color: Colors.m3.m3surfaceContainerHigh
            radius: Rounding.normal

            ColumnLayout {
                id: addDialogColumnLayout

                anchors.fill: parent
                spacing: 16

                StyledText {
                    Layout.topMargin: 16
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.alignment: Qt.AlignLeft
                    color: Colors.m3.m3onSurface
                    font.pixelSize: Fonts.sizes.verylarge
                    text: qsTr("Add Custom Timer")
                }

                TextField {
                    id: timerNameInput

                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    padding: 10
                    color: activeFocus ? Colors.m3.m3onSurface : Colors.m3.m3onSurfaceVariant
                    renderType: Text.NativeRendering
                    selectedTextColor: Colors.m3.m3onSecondaryContainer
                    selectionColor: Colors.m3.m3secondaryContainer
                    placeholderText: qsTr("Timer name")
                    placeholderTextColor: Colors.m3.m3outline
                    focus: root.showAddDialog

                    background: Rectangle {
                        anchors.fill: parent
                        radius: Rounding.verysmall
                        border.width: 2
                        border.color: timerNameInput.activeFocus ? Colors.colPrimary : Colors.m3.m3outline
                        color: "transparent"
                    }

                    cursorDelegate: Rectangle {
                        width: 1
                        color: timerNameInput.activeFocus ? Colors.colPrimary : "transparent"
                        radius: 1
                    }
                }

                RowLayout {
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 15

                    RowLayout {
                        spacing: 8

                        TextField {
                            id: timerMinutesInput

                            Layout.preferredWidth: 60
                            padding: 10
                            inputMethodHints: Qt.ImhDigitsOnly
                            placeholderText: "0"
                            placeholderTextColor: Colors.m3.m3outline
                            color: activeFocus ? Colors.m3.m3onSurface : Colors.m3.m3onSurfaceVariant

                            validator: IntValidator {
                                bottom: 0
                                top: 999
                            }

                            background: Rectangle {
                                anchors.fill: parent
                                radius: Rounding.verysmall
                                border.width: 2
                                border.color: timerMinutesInput.activeFocus ? Colors.colPrimary : Colors.m3.m3outline
                                color: "transparent"
                            }
                        }

                        StyledText {
                            text: qsTr("min")
                            color: Colors.m3.m3onSurfaceVariant
                        }
                    }

                    RowLayout {
                        spacing: 8

                        TextField {
                            id: timerSecondsInput

                            Layout.preferredWidth: 60
                            padding: 10
                            inputMethodHints: Qt.ImhDigitsOnly
                            placeholderText: "0"
                            placeholderTextColor: Colors.m3.m3outline
                            color: activeFocus ? Colors.m3.m3onSurface : Colors.m3.m3onSurfaceVariant

                            validator: IntValidator {
                                bottom: 0
                                top: 59
                            }

                            background: Rectangle {
                                anchors.fill: parent
                                radius: Rounding.verysmall
                                border.width: 2
                                border.color: timerSecondsInput.activeFocus ? Colors.colPrimary : Colors.m3.m3outline
                                color: "transparent"
                            }
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("sec")
                            color: Colors.m3.m3onSurfaceVariant
                        }
                    }
                }

                RowLayout {
                    Layout.bottomMargin: 16
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.alignment: Qt.AlignRight
                    spacing: 5

                    DialogButton {
                        buttonText: qsTr("Cancel")
                        onClicked: root.showAddDialog = false
                    }

                    DialogButton {
                        buttonText: qsTr("Add Timer")
                        enabled: (parseInt(timerMinutesInput.text) || 0) > 0 || (parseInt(timerSecondsInput.text) || 0) > 0
                        onClicked: addDialog.addCustomTimer()
                    }
                }
            }
        }

        Behavior on opacity {
            FAnim {}
        }
    }
}
