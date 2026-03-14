import Quickshell
import Quickshell.Hyprland
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services

QuickToggleButton {
    buttonName: toggled ? "Row" : "Accel"
    buttonIcon: "mouse"
    onClicked: {
        toggled = !toggled;
        if (toggled)
            NoonUtils.execDetached(`hyprctl keyword input:force_no_accel ${toggled ? 1 : 0}`);
        else
            NoonUtils.execDetached(`hyprctl keyword input:force_no_accel ${toggled ? 1 : 0}`);
    }
}
