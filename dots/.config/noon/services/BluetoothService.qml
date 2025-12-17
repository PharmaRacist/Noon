pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: (adapter && adapter.powered) ?? false  // Changed from 'enabled' to 'powered'
    readonly property bool discovering: (adapter && adapter.discovering) ?? false
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
            return dev && dev.batteryPercentage !== undefined && dev.batteryPercentage >= 0;  // Changed from 'batteryAvailable' and 'battery'
        });
    }

    // Service methods for discovery
    function startDiscovery() {
        // console.log("Starting discovery - Adapter:", adapter, "Powered:", enabled, "Discovering:", discovering);
        if (adapter && enabled && !discovering) {
            // console.log("Calling startDiscovery()");
            adapter.startDiscovery();
        } else
        // console.log("Cannot start discovery - Adapter:", !!adapter, "Powered:", enabled, "Already discovering:", discovering);
        {}
    }

    function stopDiscovery() {
        console.log("Stopping discovery");
        if (adapter && discovering) {
            adapter.stopDiscovery();
        }
    }

    // Service methods for device operations
    function connectDevice(device) {
        if (device && !isDeviceBusy(device)) {
            console.log("Connecting to device:", device.name || device.address);
            device.connect();
        }
    }

    function disconnectDevice(device) {
        if (device && device.connected && !isDeviceBusy(device)) {
            console.log("Disconnecting from device:", device.name || device.address);
            device.disconnect();
        }
    }

    function pairDevice(device) {
        if (device && !device.paired && !isDeviceBusy(device)) {
            console.log("Pairing with device:", device.name || device.address);
            device.pair();
        }
    }

    function unpairDevice(device) {
        if (device && device.paired && !isDeviceBusy(device)) {
            console.log("Unpairing device:", device.name || device.address);
            // Note: Check if unpair() method exists, might need to use different approach
            if (typeof device.unpair === "function") {
                device.unpair();
            } else {
                console.log("Unpair method not available");
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

    // Utility functions
    function sortDevices(devices) {
        return devices.sort((a, b) => {
            // Prioritize connected devices
            if (a.connected && !b.connected)
                return -1;
            if (!a.connected && b.connected)
                return 1;

            // Then paired devices
            if (a.paired && !b.paired)
                return -1;
            if (!a.paired && b.paired)
                return 1;

            // Then devices with real names
            var aName = a.name || a.alias || "";  // Added 'alias' as fallback
            var bName = b.name || b.alias || "";
            var aHasRealName = aName.includes(" ") && aName.length > 3;
            var bHasRealName = bName.includes(" ") && bName.length > 3;

            if (aHasRealName && !bHasRealName)
                return -1;
            if (!aHasRealName && bHasRealName)
                return 1;

            // Finally by signal strength (RSSI)
            var aSignal = (a.rssi !== undefined && a.rssi < 0) ? Math.abs(a.rssi) : 999;  // Changed from 'signalStrength' to 'rssi'
            var bSignal = (b.rssi !== undefined && b.rssi < 0) ? Math.abs(b.rssi) : 999;
            return aSignal - bSignal;  // Lower RSSI (closer to 0) is better
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
        if (!device || device.rssi === undefined)  // Changed from 'signalStrength' to 'rssi'
            return "Unknown";

        // RSSI values are negative, closer to 0 is better
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
        // Check if the device has connecting/disconnecting states
        return device.pairing || (device.connecting !== undefined && device.connecting);
    }

    function getBatteryIcon(device) {
        if (!device || device.batteryPercentage === undefined || device.batteryPercentage < 0)  // Changed from 'batteryAvailable' and 'battery'
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

    // Device filtering helpers
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

    function filterConnectedDevices(devices) {
        return devices.filter(device => device && device.connected);
    }
}
