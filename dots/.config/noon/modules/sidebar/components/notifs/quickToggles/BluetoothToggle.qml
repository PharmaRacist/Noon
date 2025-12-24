import QtQuick
import Quickshell
import qs.modules.common
import qs.services

QuickToggleButton {
    hasDialog: true
    toggled: BluetoothService.available > 0
    buttonIcon: BluetoothService.currentDeviceIcon
    buttonName: BluetoothService.filterConnectedDevices(BluetoothService.pairedDevices).length > 0 ? (BluetoothService.filterConnectedDevices(BluetoothService.pairedDevices)[0].name || "Connected") : "Bluetooth"
    onRequestDialog: GlobalStates.showBluetoothDialog = true
    onClicked: BluetoothService.togglePower()
}
