import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services

QuickToggleButton {
    id: root

    signal requestTransparencyDialog()

    hasDialog: true
    onRequestDialog: GlobalStates.showTransparencyDialog = true
    buttonName: toggled ? "Transluscent" : "opaque"
    toggled: Mem.options.appearance.transparency
    buttonIcon: toggled ? "blur_on" : "blur_off"
    onClicked: Mem.options.appearance.transparency = !toggled
    altAction: () => {
        requestTransparencyDialog();
    }
}
