import Quickshell
import qs.common
import qs.services

QuickToggleButton {
    readonly property var device: KdeConnectService.availableDevices[0] || KdeConnectService.devices[0]
    readonly property bool isAvailable: KdeConnectService.availableDevices.length > 0

    hasDialog: true
    showButtonName: true
    buttonName: device?.name || "No Devices"
    toggled: isAvailable
    buttonIcon: isAvailable ? "phonelink" : "phonelink_off"
    onRequestDialog: GlobalStates.main.dialogs.showKdeConnectDialog = true
    onClicked: KdeConnectService.togglePower()
}
