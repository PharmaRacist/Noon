import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services
import qs

QuickToggleButton {
    property bool showWifiDialog: false
    hasDialog:true
    buttonName: `${Network.networkName} `
    toggled: Network.networkName.length > 0 && Network.networkName != "lo"
    buttonIcon: Network.materialSymbol
    onRequestDialog:GlobalStates.showWifiDialog = true
    onClicked: {
        toggleNetwork.running = true;
    }

    Process {
        id: toggleNetwork

        command: ["bash", "-c", "nmcli radio wifi | grep -q enabled && nmcli radio wifi off || nmcli radio wifi on"]
        onRunningChanged: {
            if (!running)
                Network.update();

        }
    }
}
