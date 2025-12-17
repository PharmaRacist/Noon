import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Item {
    id: root

    property var timerList: []
    property string emptyPlaceholderIcon: "timer"
    property int listBottomPadding: 0

    signal startTimer(int timerId)
    signal pauseTimer(int timerId)
    signal resetTimer(int timerId)
    signal removeTimer(int timerId)

    StyledListView {
        id: listView

        anchors.fill: parent
        anchors.topMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: root.listBottomPadding
        spacing: 8
        model: root.timerList
        clip: true

        // Empty state
        Item {
            anchors.centerIn: parent
            // visible: root.timerList.length === 0
            width: parent.width
            height: 200
        }

        delegate: TimerCard {
            width: listView.width
            timerId: modelData.id
            timerName: modelData.name
            originalDuration: modelData.originalDuration
            remainingTime: modelData.remainingTime
            isRunning: modelData.isRunning
            isPaused: modelData.isPaused
            timerIcon: modelData.icon
            progressPercentage: ((modelData.originalDuration - modelData.remainingTime) / modelData.originalDuration) * 100
            onStartRequested: root.startTimer(timerId)
            onPauseRequested: root.pauseTimer(timerId)
            onResetRequested: root.resetTimer(timerId)
            onRemoveRequested: root.removeTimer(timerId)
        }

    }

}
