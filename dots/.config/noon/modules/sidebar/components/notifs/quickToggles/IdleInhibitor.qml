import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services

QuickToggleButton {
    id: root

    showButtonName: false
    toggled: inhibit.enabled // Bind to the inhibitor, not idle state
    buttonIcon: "coffee"
    buttonName: inhibit.enabled ? "Awake" : "Sleepy"
    onClicked: {
        inhibit.enabled = !inhibit.enabled;
    }

    IdleInhibitor {
        id: inhibit

        window: null
    }

    IdleMonitor {
        id: idleMonitor

        respectInhibitors: true
    }

    StyledToolTip {
        content: qsTr("Keep system awake")
    }

}
