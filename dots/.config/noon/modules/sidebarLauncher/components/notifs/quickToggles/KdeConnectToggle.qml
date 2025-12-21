import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services

QuickToggleButton {
    id: kdeconnectd
    
    readonly property var device: KdeConnectService.availableDevices[0] || KdeConnectService.devices[0]
    readonly property int availableCount: KdeConnectService.availableDevices.length
    readonly property bool hasDevices: KdeConnectService.devices.length > 0
    
    showButtonName: true
    buttonName: {
        if (!hasDevices) return "No Devices";
        if (availableCount === 0) return device?.name || "Offline";
        if (availableCount === 1) return device.name;
        return `${device.name} (+${availableCount - 1})`;
    }
    
    hasDialog: hasDevices
    onRequestDialog: GlobalStates.showKdeConnectDialog = true
    
    toggled: availableCount > 0
    buttonIcon: availableCount > 0 ? "phonelink" : "phonelink_off"
    
    onClicked: {
        if (hasDevices) {
            KdeConnectService.refresh();
        } else {
            GlobalStates.showKdeConnectDialog = true;
        }
    }
    
    enabled: !KdeConnectService.isRefreshing
}