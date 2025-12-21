import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services

QuickToggleButton {
    hasDialog: true
    toggled: BluetoothService.enabled
    buttonIcon: BluetoothService.bluetoothConnected ? "bluetooth_connected" : BluetoothService.enabled ? "bluetooth" : "bluetooth_disabled"
    buttonName: BluetoothService.bluetoothConnected ? BluetoothService.bluetoothDeviceName : "Bluetooth"
    onRequestDialog: GlobalStates.showBluetoothDialog = true
    onClicked: {
        toggleBluetooth.running = !toggleBluetooth.running;
    }
    holdAction: () => {
        Noon.exec(Mem.options.apps.bluetooth);
        Noon.callIpc("sidebar_launcher hide");
    }

    Process {
        id: toggleBluetooth

        command: ["bash", "-c", `bluetoothctl power ${BluetoothService.enabled ? "off" : "on"}`]
        onRunningChanged: {
            if (!running)
                BluetoothService.update();

        }
    }

}
