import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

Rectangle {
    id: bigTimerWidget

    property var displayTimers: []
    property var activeTimers: []
    property int updateCounter: 0
    property int selectedTimerIndex: 0
    readonly property var selectedTimer: {
        const _ = updateCounter;
        if (activeTimers.length === 0)
            return null;
        const idx = Math.min(selectedTimerIndex, activeTimers.length - 1);
        return idx >= 0 ? activeTimers[idx] : null;
    }
    readonly property bool hasActiveTimers: activeTimers.length > 0

    function updateTimers() {
        const allTimers = [];
        for (let i = 0; i < TimerService.timers.length; i++) {
            allTimers.push(TimerService.timers[i]);
        }
        displayTimers = allTimers;

        const filtered = [];
        for (let i = 0; i < allTimers.length; i++) {
            const timer = allTimers[i];
            if (timer.isRunning || timer.isPaused) {
                filtered.push(timer);
            }
        }
        activeTimers = filtered;
        updateCounter++;
    }

    Connections {
        target: TimerService
        function onTimersChanged() {
            bigTimerWidget.updateTimers();
        }
        function onTimersLoaded() {
            bigTimerWidget.updateTimers();
        }
    }

    Component.onCompleted: {
        updateTimers();
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: bigTimerWidget.updateTimers()
    }

    visible: true
    radius: Appearance.rounding.verylarge
    color: hasActiveTimers ? Appearance.colors.colLayer1 : "transparent"

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    // Main content loader
    Loader {
        anchors.centerIn: parent
        sourceComponent: hasActiveTimers ? activeTimerComponent : emptyStateComponent
    }

    // Active timer component
    Component {
        id: activeTimerComponent

        ColumnLayout {
            spacing: Appearance.padding.normal

            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 250
                Layout.preferredHeight: 250

                CircularProgress {
                    id: mainProgress
                    anchors.centerIn: parent
                    lineWidth: 20
                    fill: false
                    value: {
                        const _ = bigTimerWidget.updateCounter;
                        if (!bigTimerWidget.selectedTimer || !bigTimerWidget.selectedTimer.originalDuration || bigTimerWidget.selectedTimer.originalDuration === 0) {
                            return 0;
                        }
                        const remaining = bigTimerWidget.selectedTimer.remainingTime || 0;
                        const elapsed = bigTimerWidget.selectedTimer.originalDuration - remaining;
                        const progress = elapsed / bigTimerWidget.selectedTimer.originalDuration;
                        return Math.max(0, Math.min(1, progress));
                    }
                    size: 250
                    secondaryColor: Appearance.colors.m3.m3outline
                    primaryColor: bigTimerWidget.selectedTimer ? (bigTimerWidget.selectedTimer.color || Appearance.colors.m3.m3primary) : Appearance.colors.m3.m3secondary
                    StyledText {
                        id: timerTime
                        anchors.centerIn: parent
                        text: {
                            const _ = bigTimerWidget.updateCounter;
                            return bigTimerWidget.selectedTimer ? TimerService.formatTime(bigTimerWidget.selectedTimer.remainingTime || 0) : "00:00";
                        }
                        font.pixelSize: 50
                        font.variableAxes: Appearance.fonts.variableAxes.numbers
                        color: Appearance.colors.colOnLayer0
                    }
                    Loader {
                        anchors.top: timerTime.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        active: bigTimerWidget.activeTimers.length > 1
                        sourceComponent: timerSelectorComponent
                    }

                    Behavior on value {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.Linear
                        }
                    }
                }
            }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 48
                Layout.preferredHeight: 2
                color: Appearance.colors.colSubtext
                opacity: 0.4
                radius: 1
            }

            StyledText {
                Layout.topMargin: 20
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: 250
                text: bigTimerWidget.selectedTimer ? (bigTimerWidget.selectedTimer.name || "Unnamed Timer") : ""
                font.pixelSize: Appearance.fonts.sizes.verylarge
                color: Appearance.colors.m3.m3onSurface
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Appearance.padding.normal

                RippleButtonWithIcon {
                    materialIcon: {
                        const _ = bigTimerWidget.updateCounter;
                        return (bigTimerWidget.selectedTimer && bigTimerWidget.selectedTimer.isRunning) ? "pause" : "play_arrow";
                    }
                    enabled: bigTimerWidget.selectedTimer && bigTimerWidget.selectedTimer.remainingTime > 0
                    onClicked: {
                        if (!bigTimerWidget.selectedTimer || !bigTimerWidget.selectedTimer.id)
                            return;

                        if (bigTimerWidget.selectedTimer.isRunning) {
                            TimerService.pauseTimer(bigTimerWidget.selectedTimer.id);
                        } else {
                            TimerService.startTimer(bigTimerWidget.selectedTimer.id);
                        }

                        Qt.callLater(bigTimerWidget.updateTimers);
                    }
                }

                RippleButtonWithIcon {
                    materialIcon: "restart_alt"
                    enabled: bigTimerWidget.selectedTimer !== null
                    onClicked: {
                        if (!bigTimerWidget.selectedTimer || !bigTimerWidget.selectedTimer.id)
                            return;
                        TimerService.resetTimer(bigTimerWidget.selectedTimer.id);
                        Qt.callLater(bigTimerWidget.updateTimers);
                    }
                }

                RippleButtonWithIcon {
                    materialIcon: "delete"
                    enabled: bigTimerWidget.selectedTimer !== null
                    onClicked: {
                        if (!bigTimerWidget.selectedTimer || !bigTimerWidget.selectedTimer.id)
                            return;
                        TimerService.removeTimer(bigTimerWidget.selectedTimer.id);
                        Qt.callLater(bigTimerWidget.updateTimers);
                    }
                }
            }
        }
    }

    // Empty state component
    Component {
        id: emptyStateComponent

        ColumnLayout {
            spacing: 20

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: "lets Noon <3"
                font.pixelSize: 32
                font.weight: Font.Bold
                color: Appearance.colors.m3.m3onSurface
            }

            TextField {
                id: timerInput
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 300
                Layout.preferredHeight: 80
                placeholderText: "but for how long ?"
                font.pixelSize: 28
                horizontalAlignment: Text.AlignHCenter
                color: Appearance.colors.m3.m3onSurface
                cursorVisible: false

                background: Rectangle {
                    color: "transparent"
                    border.color: "transparent"
                }

                onAccepted: {
                    const duration = TimerService.parseTimeString(timerInput.text);
                    if (duration > 0) {
                        const id = TimerService.addTimer("Focus Time", duration);
                        TimerService.startTimer(id);
                        timerInput.text = "";
                    }
                }
            }
        }
    }

    // Timer selector component
    Component {
        id: timerSelectorComponent

        StyledRect {
            implicitWidth: selectorGrid.width + 10
            implicitHeight: selectorGrid.height + 10
            radius: 15
            enableShadows: true
            color: Appearance.colors.colSecondaryContainer

            Grid {
                id: selectorGrid
                anchors.centerIn: parent
                spacing: 4
                rows: 1
                columns: bigTimerWidget.activeTimers.length

                Repeater {
                    model: bigTimerWidget.activeTimers.length

                    delegate: RippleButton {
                        property var timer: bigTimerWidget.activeTimers[index]
                        property bool isSelected: index === bigTimerWidget.selectedTimerIndex

                        implicitWidth: 20
                        implicitHeight: 20
                        buttonRadius: 10

                        colBackground: isSelected ? Appearance.colors.m3.m3primary : Appearance.colors.m3.m3secondaryContainer
                        colBackgroundHover: isSelected ? Appearance.colors.m3.m3primaryHover : Appearance.colors.m3.m3secondaryContainerHover
                        colRipple: isSelected ? Appearance.colors.m3.m3primary : Appearance.colors.m3.m3secondaryContainerActive

                        onClicked: {
                            bigTimerWidget.selectedTimerIndex = index;
                        }

                        StyledToolTip {
                            extraVisibleCondition: hovered
                            content: timer?.name ?? "Timer"
                        }

                        contentItem: MaterialSymbol {
                            text: timer?.icon ?? "timer"
                            font.pixelSize: Appearance.fonts.sizes.verysmall
                            horizontalAlignment: Text.AlignHCenter
                            color: isSelected ? Appearance.colors.m3.m3onPrimary : Appearance.colors.m3.m3onSecondaryContainer
                        }
                    }
                }
            }
        }
    }
}
