import Quickshell
import Quickshell.Hyprland
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services

QuickToggleButton {
    property bool enabled: false

    buttonIcon: "mouse"
    toggled: enabled
    onClicked: {
        enabled = !enabled;
        if (enabled)
            Noon.execDetached(`hyprctl keyword input:force_no_accel ${enabled ? 1 : 0}`);
        else
            Noon.execDetached(`hyprctl keyword input:force_no_accel ${enabled ? 1 : 0}`);
    }
}
