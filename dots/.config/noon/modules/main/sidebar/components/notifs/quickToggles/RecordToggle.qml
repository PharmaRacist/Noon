import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services

QuickToggleButton {
    id: root
    dialogName: "Record"
    buttonName: RecordingService.isRecording ? "Recording " + RecordingService.getFormattedDuration() : "Record"
    toggled: RecordingService.isRecording
    buttonIcon: RecordingService.isRecording ? "radio_button_checked" : "radio_button_unchecked"
    onClicked: !toggled ? RecordingService.record() : RecordingService.stop()

    StyledToolTip {
        extraVisibleCondition: RecordingService.isRecording && !root.showButtonName
        content: root.buttonName
    }
}
