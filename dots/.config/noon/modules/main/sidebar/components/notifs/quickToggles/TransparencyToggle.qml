import QtQuick
import Quickshell
import qs.common

QuickToggleButton {
    id: root

    signal requestTransparencyDialog

    hasDialog: true
    onRequestDialog: GlobalStates.main.dialogs.showTransparencyDialog = true
    buttonName: toggled ? "Clear" : "opaque"
    toggled: Mem.options.appearance.transparency.enabled
    buttonIcon: toggled ? "blur_on" : "blur_off"
    onClicked: Mem.options.appearance.transparency.enabled = !Mem.options.appearance.transparency.enabled
    altAction: () => {
        requestTransparencyDialog();
    }
}
