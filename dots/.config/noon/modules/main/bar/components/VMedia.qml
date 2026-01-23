import qs.common
import qs.common.widgets
import qs.services
import qs.store
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    Layout.fillWidth: true
    Layout.preferredHeight: progress.implicitSize

    ClippedFilledCircularProgress {
        id: progress
        value: BeatsService.currentTrackProgressRatio()
        anchors.centerIn: parent
        implicitSize: Math.min(BarData.currentBarExclusiveSize, 35) * 0.75
        Symbol {
            fill: 1
            anchors.centerIn: parent
            font.pixelSize: progress.implicitSize * BarData.barPadding
            text: BeatsService?.isPlaying ? "pause" : "music_note"
            color: Colors.m3.m3onSecondaryContainer
        }
    }
    MediaPopup {
        hoverTarget: mouse
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
    }
}
