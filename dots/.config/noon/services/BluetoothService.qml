pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter.powered || false
    readonly property bool discovering: adapter ? adapter.discovering : false
    readonly property var devices: adapter ? adapter.devices : null
    readonly property string currentDeviceIcon: {
                if (filterConnectedDevices(pairedDevices).length > 0)
                    return getDeviceIcon(filterConnectedDevices(pairedDevices)[0]);
                else if (connectedDevices.length > 0)
                    return "bluetooth_connected";
                else if (enabled)
                    return "bluetooth";
                else
                    "bluetooth_disabled";
            }
    readonly property var pairedDevices: {
        if (!adapter || !adapter.devices) return [];
        return adapter.devices.values.filter(dev => 
            dev && (dev.paired || dev.trusted)
        );
    }
    
    readonly property var connectedDevices: {
        if (!adapter || !adapter.devices) return [];
        return adapter.devices.values.filter(dev => dev && dev.connected);
    }
    
    readonly property var devicesWithBattery: {
        if (!adapter || !adapter.devices) return [];
        return adapter.devices.values.filter(dev => 
            dev && dev.batteryAvailable && dev.battery >= 0
        );
    }

    function startDiscovery() {
        if (adapter && enabled && !discovering) {
            adapter.startDiscovery();
        }
    }

    function stopDiscovery() {
        if (adapter && discovering) {
            adapter.stopDiscovery();
        }
    }

    function connectDevice(device) {
        if (device && !isDeviceBusy(device)) {
            device.connect();
        }
    }
    
    function disconnectDevice(device) {
        if (device && device.connected && !isDeviceBusy(device)) {
            device.disconnect();
        }
    }

    function pairDevice(device) {
        if (device && !device.paired && !isDeviceBusy(device)) {
            device.pair();
        }
    }

    function trustDevice(device) {
        if (device) {
            device.trusted = true;
        }
    }

    function untrustDevice(device) {
        if (device) {
            device.trusted = false;
        }
    }

    function connectWithTrust(device) {
        if (!device || isDeviceBusy(device)) return;
        device.trusted = true;
        device.connect();
    }

    function togglePower() {
        if (adapter && adapter.powered !== undefined) {
            adapter.powered = !adapter.powered;
        }
    }

    function sortDevices(devices) {
        if (!devices) return [];
        
        return devices.sort((a, b) => {
            // Connected first
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;

            // Then paired
            if (a.paired !== b.paired)
                return a.paired ? -1 : 1;

            // Then by signal strength
            var aRssi = (a.rssi && a.rssi < 0) ? Math.abs(a.rssi) : 999;
            var bRssi = (b.rssi && b.rssi < 0) ? Math.abs(b.rssi) : 999;
            
            if (aRssi !== bRssi)
                return aRssi - bRssi;

            // Finally alphabetically
            var aName = a.name || a.alias || a.deviceName || "";
            var bName = b.name || b.alias || b.deviceName || "";
            return aName.localeCompare(bName);
        });
    }

    function getDeviceIcon(device) {
        if (!device) return "bluetooth";

        var name = (device.name || device.alias || device.deviceName || "").toLowerCase();
        var icon = (device.icon || "").toLowerCase();

        if (icon.includes("headset") || icon.includes("audio") || 
            name.includes("headphone") || name.includes("airpod") || 
            name.includes("headset") || name.includes("arctis"))
            return "headset";

        if (icon.includes("mouse") || name.includes("mouse"))
            return "mouse";

        if (icon.includes("keyboard") || name.includes("keyboard"))
            return "keyboard";

        if (icon.includes("phone") || name.includes("phone") || 
            name.includes("iphone") || name.includes("android") || 
            name.includes("samsung"))
            return "smartphone";

        if (icon.includes("watch") || name.includes("watch"))
            return "watch";

        if (icon.includes("speaker") || name.includes("speaker"))
            return "speaker";

        if (icon.includes("display") || name.includes("tv"))
            return "tv";

        return "bluetooth";
    }

    function getSignalStrength(device) {
        if (!device || device.rssi === undefined)
            return "Unknown";

        var rssi = device.rssi;
        if (rssi >= -30) return "Excellent";
        if (rssi >= -50) return "Good";
        if (rssi >= -70) return "Fair";
        if (rssi >= -85) return "Poor";
        return "Very Poor";
    }

    function getSignalIcon(device) {
        if (!device || device.rssi === undefined)
            return "signal_cellular_null";

        var rssi = device.rssi;
        if (rssi >= -30) return "signal_cellular_4_bar";
        if (rssi >= -50) return "signal_cellular_3_bar";
        if (rssi >= -70) return "signal_cellular_2_bar";
        if (rssi >= -85) return "signal_cellular_1_bar";
        return "signal_cellular_0_bar";
    }

    function getBatteryIcon(device) {
        if (!device || !device.batteryAvailable || device.battery < 0)
            return "";

        var level = Math.round(device.battery * 100);
        if (level >= 90) return "battery_full";
        if (level >= 60) return "battery_3_bar";
        if (level >= 30) return "battery_2_bar";
        if (level >= 10) return "battery_1_bar";
        return "battery_0_bar";
    }

    function getBatteryPercent(device) {
        if (!device || !device.batteryAvailable || device.battery < 0)
            return -1;
        return Math.round(device.battery * 100);
    }
    function getDeviceStatusIcon(device) {
        // if (!device) return "..";
        // if (isDeviceBusy(device)) return "Busy";
        // if (device.connected) return "Connected";
        // if (device.paired) return "Paired";
        // if (device.trusted) return "Trusted";
        return "restart_alt";
    }
    function getDeviceStatus(device) {
        if (!device) return "Unknown";
        if (isDeviceBusy(device)) return "Busy";
        if (device.connected) return "Connected";
        if (device.paired) return "Paired";
        if (device.trusted) return "Trusted";
        return "Available";
    }

    function isDeviceBusy(device) {
        if (!device) return false;
        return device.pairing || device.connecting;
    }

    function canConnect(device) {
        if (!device) return false;
        return !device.connected && !device.blocked && !isDeviceBusy(device);
    }

    function filterByName(devices, text) {
        if (!text || text.length === 0) return devices;
        return devices.filter(dev => {
            var name = (dev.name || dev.alias || dev.deviceName || "").toLowerCase();
            return name.includes(text.toLowerCase());
        });
    }

    function filterPairedDevices(devices) {
        if (!devices) return [];
        return devices.filter(dev => dev && (dev.paired || dev.trusted));
    }

    function filterConnectableDevices(devices) {
        if (!devices) return [];
        return devices.filter(dev => dev && canConnect(dev));
    }

    function filterConnectedDevices(devices) {
        if (!devices) return [];
        return devices.filter(dev => dev && dev.connected);
    }

}
