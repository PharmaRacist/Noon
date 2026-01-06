import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services

QuickToggleButton {
    id: root

    hasDialog: true
    onRequestDialog: GlobalStates.main.dialogs.showCaffaineDialog = true
    showButtonName: false
    toggled: IdleService.inhibited
    buttonIcon: "coffee"
    buttonName: toggled ? "Awake" : "Sleepy"
    onClicked: IdleService.toggleInhibit()
    altAction: () => {
        return GlobalStates.main.dialogs.showCaffaineDialog = true;
    }
}
