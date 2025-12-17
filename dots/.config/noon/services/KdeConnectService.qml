pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.utils
import QtQuick

/**
 * KDE Connect service with persistent state management
 * Storage: Uses Mem.states.services.kdeconnect
 */
Singleton {
    id: root

    // Core device data
    property var devices: []
    property var availableDevices: []
    property string selectedDeviceId: ""
    property bool isRefreshing: false
    property bool initialized: false
    property bool daemonRunning: false

    signal devicesUpdated
    signal devicePaired(string deviceId, string deviceName)
    signal deviceUnpaired(string deviceId)
    signal error(string message)

    // Auto-refresh timer
    Timer {
        id: refreshTimer
        interval: 30000
        repeat: true
        running: false
        onTriggered: root.refresh()
    }

    FilePicker {
        id: filePicker
        title: "Select file to share via KDE Connect"
        multipleSelection: true
        fileFilters: [filePicker.filterPresets.ALL, filePicker.filterPresets.IMAGES, filePicker.filterPresets.DOCUMENTS, filePicker.filterPresets.VIDEOS, filePicker.filterPresets.AUDIO]

        onFileSelected: files => {
            const deviceId = root.selectedDeviceId;
            if (!deviceId) {
                root.error("No device selected");
                return;
            }

            const fileArray = Array.isArray(files) ? files : [files];
            fileArray.forEach(file => {
                executeCommand(["--device", deviceId, "--share", file]);
            });
        }

        onCancelled: {}

        onError: message => {
            root.error(message);
        }
    }

    // Storage Operations
    function saveToConfig() {
        Mem.states.services.kdeconnect.devices = root.devices;
        Mem.states.services.kdeconnect.availableDevices = root.availableDevices;
        Mem.states.services.kdeconnect.selectedDeviceId = selectedDeviceId;
    }

    function loadFromConfig() {
        if (!Mem.states.services || !Mem.states.services.kdeconnect) {
            return;
        }

        const savedDevices = Mem.states.services.kdeconnect.devices || [];
        const savedAvailable = Mem.states.services.kdeconnect.availableDevices || [];
        const savedSelected = Mem.states.services.kdeconnect.selectedDeviceId || "";

        if (savedDevices && savedDevices.length > 0) {
            root.devices = savedDevices;
        }
        if (savedAvailable && savedAvailable.length > 0) {
            root.availableDevices = savedAvailable;
        }
        if (savedSelected) {
            selectedDeviceId = savedSelected;
        }
    }

    // Execute command helper
    function executeCommand(args, onSuccess, onError) {
        const proc = processComponent.createObject(root, {
            "commandArgs": args,
            "successCallback": onSuccess,
            "errorCallback": onError
        });
        proc.running = true;
    }

    // Parse device list output
    function parseDeviceList(output) {
        if (!output || output.trim() === "") {
            return [];
        }

        const lines = output.split('\n').filter(line => line.trim() !== '');
        const parsed = lines.map(line => {
            const spaceIndex = line.indexOf(' ');
            if (spaceIndex === -1) {
                return {
                    id: line,
                    name: line
                };
            }
            return {
                id: line.substring(0, spaceIndex),
                name: line.substring(spaceIndex + 1).trim()
            };
        });

        return parsed;
    }

    // Check if daemon is running
    function checkDaemon() {
        executeCommand(["--list-devices"], output => {
            daemonRunning = true;
        }, errOutput => {
            daemonRunning = false;
        });
    }

    // List all devices (paired, regardless of online status)
    function listAllDevices() {
        executeCommand(["--list-devices", "--id-name-only"], output => {
            root.devices = parseDeviceList(output);
            root.devices = root.devices.slice(0);
            devicesUpdated();
            saveToConfig();
        }, errOutput => {});
    }

    // List available devices (online and reachable)
    function listAvailableDevices() {
        if (isRefreshing)
            return;

        isRefreshing = true;
        executeCommand(["--list-available", "--id-name-only"], output => {
            isRefreshing = false;
            root.availableDevices = parseDeviceList(output);
            root.availableDevices = root.availableDevices.slice(0);
            devicesUpdated();
            saveToConfig();
        }, errOutput => {
            isRefreshing = false;
        });
    }

    // Refresh discovery
    function refresh() {
        if (isRefreshing)
            return;

        checkDaemon();

        executeCommand(["--refresh"], () => {
            Qt.callLater(() => {
                listAllDevices();
                listAvailableDevices();
            });
        }, errOutput => {});
    }

    // Pair device
    function pairDevice(deviceId) {
        if (!deviceId) {
            error("Device ID is required");
            return;
        }
        executeCommand(["--device", deviceId, "--pair"], output => {
            devicePaired(deviceId, getDeviceName(deviceId));
            listAvailableDevices();
        });
    }

    // Unpair device
    function unpairDevice(deviceId) {
        if (!deviceId) {
            error("Device ID is required");
            return;
        }
        executeCommand(["--device", deviceId, "--unpair"], output => {
            deviceUnpaired(deviceId);
            listAllDevices();
            listAvailableDevices();
        });
    }

    // Ring device
    function ringDevice(deviceId) {
        if (!deviceId)
            deviceId = selectedDeviceId;
        if (!deviceId) {
            error("No device selected");
            return;
        }
        executeCommand(["--device", deviceId, "--ring"]);
    }

    function pingSelectedDevice(message) {
        let deviceId = selectedDeviceId;
        const args = ["--device", deviceId];
        args.push("--ping-msg", message);
        executeCommand(args);
    }

    // Send ping
    function pingDevice(message, deviceId) {
        if (!deviceId)
            deviceId = selectedDeviceId;
        if (!deviceId) {
            error("No device selected");
            return;
        }

        const args = ["--device", deviceId];
        if (message) {
            args.push("--ping-msg", message);
        } else {
            args.push("--ping");
        }
        executeCommand(args);
    }

    // Share file or URL
    function shareFile(deviceId, path) {
        if (!deviceId)
            deviceId = selectedDeviceId;
        if (!deviceId) {
            error("No device selected");
            return;
        }

        if (!path) {
            filePicker.open();
        } else {
            executeCommand(["--device", deviceId, "--share", path]);
            Noon.notify("Sharing..");
        }
    }

    // Share text
    function shareText(deviceId, text) {
        if (!deviceId)
            deviceId = selectedDeviceId;
        if (!deviceId || !text) {
            error("Device ID and text required");
            return;
        }
        executeCommand(["--device", deviceId, "--share-text", text]);
    }

    // Send clipboard
    function sendClipboard(deviceId) {
        if (!deviceId)
            deviceId = selectedDeviceId;
        if (!deviceId) {
            error("No device selected");
            return;
        }
        executeCommand(["--device", deviceId, "--send-clipboard"]);
    }

    // Lock device
    function lockDevice(deviceId) {
        if (!deviceId)
            deviceId = selectedDeviceId;
        if (!deviceId) {
            error("No device selected");
            return;
        }
        executeCommand(["--device", deviceId, "--lock"]);
    }

    // Send SMS
    function sendSMS(deviceId, phoneNumber, message, attachments) {
        if (!deviceId)
            deviceId = selectedDeviceId;
        if (!deviceId || !phoneNumber || !message) {
            error("Device ID, phone number, and message required");
            return;
        }

        const args = ["--device", deviceId, "--send-sms", message, "--destination", phoneNumber];

        if (attachments && Array.isArray(attachments)) {
            attachments.forEach(attachment => {
                args.push("--attachment", attachment);
            });
        }

        executeCommand(args);
    }

    // Get encryption info
    function getEncryptionInfo(deviceId) {
        if (!deviceId)
            deviceId = selectedDeviceId;
        if (!deviceId) {
            error("No device selected");
            return;
        }
        executeCommand(["--device", deviceId, "--encryption-info"], output => {});
    }

    // Helper: Get device name by ID
    function getDeviceName(deviceId) {
        let device = availableDevices.find(d => d.id === deviceId);
        if (!device) {
            device = devices.find(d => d.id === deviceId);
        }
        return device ? device.name : deviceId;
    }

    // Helper: Get first available device
    function getFirstAvailableDevice() {
        return availableDevices.length > 0 ? availableDevices[0] : null;
    }

    // Helper: Check if device is online
    function isDeviceAvailable(deviceId) {
        return availableDevices.some(d => d.id === deviceId);
    }

    // Select device
    function selectDevice(deviceId) {
        selectedDeviceId = deviceId;
        saveToConfig();
    }

    Component.onCompleted: {
        loadFromConfig();

        Qt.callLater(() => {
            if (!initialized) {
                initialized = true;
                checkDaemon();
                refresh();
                refreshTimer.start();
            }
        });
    }

    // Process component factory
    Component {
        id: processComponent

        Process {
            property var commandArgs: []
            property var successCallback: null
            property var errorCallback: null
            property string outputBuffer: ""
            property string errorBuffer: ""

            command: ["kdeconnect-cli"].concat(commandArgs)
            running: false

            stdout: SplitParser {
                onRead: line => {
                    outputBuffer += line + "\n";
                }
            }

            stderr: SplitParser {
                onRead: line => {
                    errorBuffer += line + "\n";
                }
            }

            onExited: (exitCode, exitStatus) => {
                if (exitCode === 0 && successCallback) {
                    successCallback(outputBuffer.trim());
                } else if (exitCode !== 0 && errorCallback) {
                    errorCallback(errorBuffer.trim());
                    root.error(errorBuffer.trim());
                }
            }
        }
    }
}
