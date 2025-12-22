pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: (adapter && adapter.powered) 
    readonly property bool discovering: (adapter && adapter.discovering) 
    readonly property var devices: adapter ? adapter.devices : null
    readonly property var pairedDevices: {
        if (!adapter || !adapter.devices)
            return [];

        return adapter.devices.values.filter(dev => {
            return dev && (dev.paired || dev.trusted);
        });
    }
    readonly property var allDevicesWithBattery: {
        if (!adapter || !adapter.devices)
            return [];

        return adapter.devices.values.filter(dev => {
            return dev && dev.batteryPercentage !== undefined && dev.batteryPercentage >= 0;
        });
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

    function unpairDevice(device) {
        if (device && device.paired && !isDeviceBusy(device)) {
            if (typeof device.unpair === "function") {
                device.unpair();
            }
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

    function connectDeviceWithTrust(device) {
        if (!device || isDeviceBusy(device))
            return;

        device.trusted = true;
        device.connect();
    }

    function sortDevices(devices) {
        return devices.sort((a, b) => {
            if (a.connected && !b.connected)
                return -1;
            if (!a.connected && b.connected)
                return 1;

            if (a.paired && !b.paired)
                return -1;
            if (!a.paired && b.paired)
                return 1;

            var aName = a.name || a.alias || "";
            var bName = b.name || b.alias || "";
            var aHasRealName = aName.includes(" ") && aName.length > 3;
            var bHasRealName = bName.includes(" ") && bName.length > 3;

            if (aHasRealName && !bHasRealName)
                return -1;
            if (!aHasRealName && bHasRealName)
                return 1;

            var aSignal = (a.rssi !== undefined && a.rssi < 0) ? Math.abs(a.rssi) : 999;
            var bSignal = (b.rssi !== undefined && b.rssi < 0) ? Math.abs(b.rssi) : 999;
            return aSignal - bSignal;
        });
    }

    function getDeviceIcon(device) {
        if (!device)
            return "bluetooth";

        var name = (device.name || device.alias || "").toLowerCase();
        var icon = (device.icon || "").toLowerCase();

        if (icon.includes("headset") || icon.includes("audio") || name.includes("headphone") || name.includes("airpod") || name.includes("headset") || name.includes("arctis"))
            return "headset";

        if (icon.includes("mouse") || name.includes("mouse"))
            return "mouse";

        if (icon.includes("keyboard") || name.includes("keyboard"))
            return "keyboard";

        if (icon.includes("phone") || name.includes("phone") || name.includes("iphone") || name.includes("android") || name.includes("samsung"))
            return "smartphone";

        if (icon.includes("watch") || name.includes("watch"))
            return "watch";

        if (icon.includes("speaker") || name.includes("speaker"))
            return "speaker";

        if (icon.includes("display") || name.includes("tv"))
            return "tv";

        return "bluetooth";
    }

    function canConnect(device) {
        if (!device)
            return false;

        return !device.connected && !device.paired && !isDeviceBusy(device) && !device.blocked;
    }

    function getSignalStrength(device) {
        if (!device || device.rssi === undefined)
            return "Unknown";

        var rssi = device.rssi;
        if (rssi >= -30)
            return "Excellent";
        if (rssi >= -50)
            return "Good";
        if (rssi >= -70)
            return "Fair";
        if (rssi >= -85)
            return "Poor";
        return "Very Poor";
    }

    function getSignalIcon(device) {
        if (!device || device.rssi === undefined)
            return "signal_cellular_null";

        var rssi = device.rssi;
        if (rssi >= -30)
            return "signal_cellular_4_bar";
        if (rssi >= -50)
            return "signal_cellular_3_bar";
        if (rssi >= -70)
            return "signal_cellular_2_bar";
        if (rssi >= -85)
            return "signal_cellular_1_bar";
        return "signal_cellular_0_bar";
    }

    function isDeviceBusy(device) {
        if (!device)
            return false;
        return device.pairing || (device.connecting !== undefined && device.connecting);
    }

    function getBatteryIcon(device) {
        if (!device || device.batteryPercentage === undefined || device.batteryPercentage < 0)
            return "";

        var level = device.batteryPercentage;
        if (level >= 90)
            return "battery_full";
        if (level >= 60)
            return "battery_3_bar";
        if (level >= 30)
            return "battery_2_bar";
        if (level >= 10)
            return "battery_1_bar";
        return "battery_0_bar";
    }

    function getDeviceStatusText(device) {
        if (!device)
            return "Unknown";
        if (isDeviceBusy(device))
            return "Busy";
        if (device.connected)
            return "Connected";
        if (device.paired)
            return "Paired";
        if (device.trusted)
            return "Trusted";
        return "Available";
    }

    function filterByText(devices, filterText) {
        if (!filterText || filterText.length === 0)
            return devices;

        return devices.filter(device => {
            var deviceName = (device.name || device.alias || "").toLowerCase();
            return deviceName.includes(filterText.toLowerCase());
        });
    }

    function filterPairedDevices(devices) {
        return devices.filter(device => device && (device.paired || device.trusted));
    }

    function filterConnectableDevices(devices) {
        return devices.filter(device => device && canConnect(device));
    }
    function togglePower() {
        if (adapter) {
            adapter.powered = !adapter.powered;
        }
    }
    function filterConnectedDevices(devices) {
        return devices.filter(device => device && device.connected);
    }
}
