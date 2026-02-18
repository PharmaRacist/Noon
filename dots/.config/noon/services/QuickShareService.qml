pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import qs.common

Singleton {
    id: root

    // ── Public read-only properties ──────────────────────────────────────────
    readonly property bool backendReady: _s.backendReady
    readonly property bool receiving: _s.receiving
    readonly property string lastError: _s.lastError
    readonly property var discoveredDevices: _s.discoveredDevices
    readonly property real sendProgress: _s.sendProgress
    readonly property real receiveProgress: _s.receiveProgress

    // Populated once the backend starts advertising.
    // Fields:
    //   endpointName  – human-readable local device name
    //   ip            – IP address others should connect to
    //   port          – port number
    //   qrData        – raw string to encode in a QR code
    //                   (typically "nearby://<ip>:<port>?name=<endpointName>")
    //   authToken     – optional short auth token / PIN shown to both sides
    readonly property QtObject receiveInfo: _receiveInfo

    QtObject {
        id: _receiveInfo
        property string endpointName: ""
        property string ip: ""
        property int port: 0
        property string qrData: ""
        property string authToken: ""

        // Convenience: true once we have at least an ip+port
        readonly property bool valid: ip !== "" && port > 0
    }

    // ── Signals ──────────────────────────────────────────────────────────────
    signal transferRequest(string sender, var files, int totalBytes)
    signal transferComplete(var files, string outputDir)
    signal sendComplete(string fileName)
    signal deviceFound(int index, string name)
    signal discoverDone(int total)
    signal error(string message)
    // Emitted when receiveInfo is freshly populated so the UI can react
    signal receiveInfoReady

    // ── Public API ───────────────────────────────────────────────────────────
    function startReceiving(outputDir) {
        _cmd({
            cmd: "startReceiving",
            outputDir: outputDir || ""
        });
    }

    function stopReceiving() {
        _clearReceiveInfo();
        _cmd({
            cmd: "stopReceiving"
        });
    }

    function sendFile(deviceIndex, path) {
        _cmd({
            cmd: "sendFile",
            deviceIndex: deviceIndex,
            path: path
        });
    }

    function discoverDevices() {
        _s.discoveredDevices = [];
        _cmd({
            cmd: "discoverDevices"
        });
    }

    function ping() {
        _cmd({
            cmd: "ping"
        });
    }

    // ── Internal helpers ─────────────────────────────────────────────────────
    function _cmd(obj) {
        if (!_proc.running) {
            console.warn("QuickShare: backend not running");
            return;
        }
        _proc.write(JSON.stringify(obj) + "\n");
    }

    function _clearReceiveInfo() {
        _receiveInfo.endpointName = "";
        _receiveInfo.ip = "";
        _receiveInfo.port = 0;
        _receiveInfo.qrData = "";
        _receiveInfo.authToken = "";
    }

    function _onEvent(raw) {
        var o;
        try {
            o = JSON.parse(raw);
        } catch (e) {
            return;
        }

        switch (o.event) {
        case "ready":
            _s.backendReady = true;
            break;

        // Backend started advertising – carries the endpoint advertisement so
        // the UI can render a QR code for the sender to scan.
        case "receiving":
            _s.receiving = true;
            _receiveInfo.endpointName = o.endpointName || "";
            _receiveInfo.ip = o.ip || "";
            _receiveInfo.port = o.port || 0;
            _receiveInfo.authToken = o.authToken || "";
            // Build the qrData string if the backend didn't supply one
            if (o.qrData) {
                _receiveInfo.qrData = o.qrData;
            } else if (_receiveInfo.ip && _receiveInfo.port) {
                var name = encodeURIComponent(_receiveInfo.endpointName);
                _receiveInfo.qrData = "nearby://" + _receiveInfo.ip + ":" + _receiveInfo.port + (name ? "?name=" + name : "");
            }
            if (_receiveInfo.valid)
                root.receiveInfoReady();
            break;
        case "stopped":
            _s.receiving = false;
            _clearReceiveInfo();
            break;
        case "transferRequest":
            root.transferRequest(o.sender || "", o.files || [], o.totalBytes || 0);
            break;
        case "transferComplete":
            root.transferComplete(o.files || [], o.outputDir || "");
            break;
        case "sendComplete":
            _s.sendProgress = -1;
            root.sendComplete(o.fileName || "");
            break;
        case "sendProgress":
            _s.sendProgress = o.progress || 0;
            break;
        case "receiveProgress":
            _s.receiveProgress = o.progress || 0;
            break;
        case "deviceFound":
            var devs = _s.discoveredDevices.slice();
            devs.push({
                index: o.index,
                name: o.name
            });
            _s.discoveredDevices = devs;
            root.deviceFound(o.index, o.name || "");
            break;
        case "discoverDone":
            root.discoverDone(o.total || 0);
            break;
        case "error":
            _s.lastError = o.message || "";
            root.error(_s.lastError);
            break;
        case "pong":
            break;
        default:
            console.warn("QuickShare: unknown event:", o.event);
            break;
        }
    }

    // ── Private state ────────────────────────────────────────────────────────
    QtObject {
        id: _s
        property bool backendReady: false
        property bool receiving: false
        property string lastError: ""
        property var discoveredDevices: []
        property real sendProgress: -1
        property real receiveProgress: -1
    }

    // ── Backend process ──────────────────────────────────────────────────────
    Process {
        id: _proc
        readonly property string scriptPath: Directories.scriptsDir + "/pyquickshare_service.py"
        command: ["uv", "--directory", Directories.venv, "run", scriptPath]
        running: true
        stdinEnabled: true

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => root._onEvent(line.trim())
        }
        stderr: SplitParser {
            splitMarker: "\n"
            onRead: line => console.log("[qs]", line)
        }
        onExited: code => {
            _s.backendReady = false;
            _s.receiving = false;
            _clearReceiveInfo();
            if (code !== 0)
                _restart.restart();
        }
    }

    Timer {
        id: _restart
        interval: 3000
        onTriggered: {
            _proc.running = true;
        }
    }
}
