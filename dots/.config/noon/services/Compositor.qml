pragma Singleton
pragma ComponentBehavior: Bound
import QtCore
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.modules.common

Singleton {
    id: root

    // Detect compositor type
    readonly property bool isHyprland: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") !== ""
    readonly property bool isNiri: Quickshell.env("NIRI_SOCKET") !== ""
    readonly property string compositorType: isHyprland ? "hyprland" : (isNiri ? "niri" : "unknown")

    // ========== UNIFIED INTERFACE ==========

    // Window data
    property var windowList: []
    property var addresses: []
    property var windowByAddress: ({})

    // Workspace data - unified object that mimics Hyprland.workspaces
    property var workspaces: QtObject {
        property var values: []
    }
    property var workspaceIds: []
    property var workspaceById: ({})
    property var activeWorkspace: null

    // Display data
    property var monitors: []
    property var layers: ({})

    // ========== HELPER FUNCTIONS ==========

    function updateAll() {
        if (isNiri) {
            niriWindowsProcess.running = true;
            niriWorkspacesProcess.running = true;
            niriOutputsProcess.running = true;
            Mem.states.services.wm.niri = true;
            Mem.states.services.wm.hypr = false;
        } else if (isHyprland) {
            Mem.states.services.wm.hypr = true;
            Mem.states.services.wm.niri = false;
            updateHyprlandData();
        }
    }

    function biggestWindowForWorkspace(workspaceId) {
        const windowsInWorkspace = windowList.filter(w => {
            if (isNiri) {
                const ws = workspaceById[w.workspace_id];
                return ws?.id === workspaceId;
            } else {
                return w.workspace?.id === workspaceId;
            }
        });
        return windowsInWorkspace.reduce((maxWin, win) => {
            const maxArea = (maxWin?.size?.[0] ?? 0) * (maxWin?.size?.[1] ?? 0);
            const winArea = (win?.size?.[0] ?? 0) * (win?.size?.[1] ?? 0);
            return winArea > maxArea ? win : maxWin;
        }, null);
    }

    // Unified workspace getter
    function getWorkspaceId(window) {
        if (!window)
            return null;
        if (isNiri) {
            const ws = workspaceById[window.workspace_id];
            return ws?.id ?? null;
        } else {
            return window.workspace?.id;
        }
    }

    // Unified app_id/class getter
    function getWindowClass(window) {
        if (!window)
            return null;
        if (isNiri) {
            return window.app_id;
        } else {
            return window.class;
        }
    }

    Component.onCompleted: updateAll()

    // ========== HYPRLAND IMPLEMENTATION ==========

    Connections {
        target: isHyprland ? Hyprland : null
        function onRawEvent(event) {
            updateHyprlandData();
        }
    }

    function updateHyprlandData() {
        if (!isHyprland)
            return;
        hyprGetClients.running = true;
        hyprGetMonitors.running = true;
        hyprGetLayers.running = true;
        hyprGetWorkspaces.running = true;
        hyprGetActiveWorkspace.running = true;
    }

    Process {
        id: hyprGetClients
        command: ["hyprctl", "clients", "-j"]
        running: false
        stdout: SplitParser {
            id: clientsCollector
            onRead: data => {
                try {
                    processHyprlandWindows(JSON.parse(data));
                } catch (e) {
                    console.error("CompositorService: Failed to parse Hyprland clients:", e);
                }
            }
        }
    }

    Process {
        id: hyprGetMonitors
        command: ["hyprctl", "monitors", "-j"]
        running: false
        stdout: SplitParser {
            id: monitorsCollector
            onRead: data => {
                try {
                    processHyprlandMonitors(JSON.parse(data));
                } catch (e) {
                    console.error("CompositorService: Failed to parse Hyprland monitors:", e);
                }
            }
        }
    }

    Process {
        id: hyprGetLayers
        command: ["hyprctl", "layers", "-j"]
        running: false
        stdout: SplitParser {
            id: layersCollector
            onRead: data => {
                try {
                    processHyprlandLayers(JSON.parse(data));
                } catch (e) {
                    console.error("CompositorService: Failed to parse Hyprland layers:", e);
                }
            }
        }
    }

    Process {
        id: hyprGetWorkspaces
        command: ["hyprctl", "workspaces", "-j"]
        running: false
        stdout: SplitParser {
            id: workspacesCollector
            onRead: data => {
                try {
                    processHyprlandWorkspaces(JSON.parse(data));
                } catch (e) {
                    console.error("CompositorService: Failed to parse Hyprland workspaces:", e);
                }
            }
        }
    }

    Process {
        id: hyprGetActiveWorkspace
        command: ["hyprctl", "activeworkspace", "-j"]
        running: false
        stdout: SplitParser {
            id: activeWorkspaceCollector
            onRead: data => {
                try {
                    processHyprlandActiveWorkspace(JSON.parse(data));
                } catch (e) {
                    console.error("CompositorService: Failed to parse Hyprland active workspace:", e);
                }
            }
        }
    }

    function processHyprlandWindows(clients) {
        windowList = clients;
        const tempWinByAddress = {};
        for (const win of clients) {
            tempWinByAddress[win.address] = win;
        }
        windowByAddress = tempWinByAddress;
        addresses = clients.map(win => win.address);
    }

    function processHyprlandMonitors(monitorData) {
        monitors = monitorData;
    }

    function processHyprlandLayers(layerData) {
        layers = layerData;
    }

    function processHyprlandWorkspaces(workspaceData) {
        // Update workspaces.values to mimic Hyprland.workspaces
        workspaces.values = workspaceData;

        const tempWorkspaceById = {};
        for (const ws of workspaceData) {
            tempWorkspaceById[ws.id] = ws;
        }
        workspaceById = tempWorkspaceById;
        workspaceIds = workspaceData.map(ws => ws.id);
    }

    function processHyprlandActiveWorkspace(workspaceData) {
        activeWorkspace = workspaceData;
    }

    // ========== NIRI IMPLEMENTATION ==========

    Timer {
        id: niriUpdateTimer
        interval: 100
        repeat: true
        running: root.isNiri
        triggeredOnStart: false

        property int niriUpdateCounter: 0

        onTriggered: {
            niriWorkspacesProcess.running = true;

            if (niriUpdateCounter % 5 === 0) {
                niriWindowsProcess.running = true;
            }

            niriUpdateCounter++;
        }
    }

    Process {
        id: niriWindowsProcess
        command: ["niri", "msg", "-j", "windows"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                try {
                    const windowsData = JSON.parse(data);
                    processNiriWindows(windowsData);
                } catch (e) {
                    console.warn("CompositorService: Failed to parse niri windows:", e);
                }
            }
        }
    }

    Process {
        id: niriWorkspacesProcess
        command: ["niri", "msg", "-j", "workspaces"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                try {
                    const workspacesData = JSON.parse(data);
                    processNiriWorkspaces(workspacesData);
                } catch (e) {
                    console.warn("CompositorService: Failed to parse niri workspaces:", e);
                }
            }
        }
    }

    Process {
        id: niriOutputsProcess
        command: ["niri", "msg", "-j", "outputs"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                try {
                    const outputsData = JSON.parse(data);
                    processNiriMonitors(outputsData);
                } catch (e) {
                    console.warn("CompositorService: Failed to parse niri outputs:", e);
                }
            }
        }
    }

    function processNiriWindows(windowsData) {
        // Normalize windows to have a consistent interface
        const normalizedWindows = [];
        for (const w of windowsData) {
            const normalized = {
                id: w.id,
                title: w.title,
                app_id: w.app_id,
                pid: w.pid,
                workspace_id: w.workspace_id,
                is_focused: w.is_focused,
                is_floating: w.is_floating,
                is_urgent: w.is_urgent,
                layout: w.layout,
                size: w.layout ? [w.layout.window_size?.[0] ?? 0, w.layout.window_size?.[1] ?? 0] : [0, 0],
                // Hyprland-compatible properties
                address: w.id.toString(),
                class: w.app_id,
                workspace: {
                    id: 1 // Will be updated after workspaces are processed
                }
            };
            normalizedWindows.push(normalized);
        }

        windowList = normalizedWindows;

        const tempWinByAddress = {};
        for (const win of normalizedWindows) {
            tempWinByAddress[win.id] = win;
        }

        windowByAddress = tempWinByAddress;
        addresses = normalizedWindows.map(win => win.id);

        // Update workspace references in windows if workspaces are loaded
        if (workspaces.values.length > 0) {
            updateWindowWorkspaceReferences();
        }
    }

    function processNiriWorkspaces(workspacesData) {
        const unifiedWorkspaces = [];
        const tempWorkspaceById = {};

        for (const ws of workspacesData) {
            const unified = {
                // Hyprland-compatible properties
                id: ws.idx + 1,
                name: (ws.idx + 1).toString(),
                monitor: ws.output ?? "",
                windows: 0 // Will be calculated after
                ,
                hasfullscreen: false,
                lastwindow: ws.active_window_id ?? null,
                lastwindowtitle: "",
                // Niri-specific fields
                idx: ws.idx,
                niri_id: ws.id,
                is_urgent: ws.is_urgent,
                is_active: ws.is_active,
                is_focused: ws.is_focused,
                output: ws.output
            };
            unifiedWorkspaces.push(unified);

            // Map BOTH by unified id AND by niri_id
            tempWorkspaceById[unified.id] = unified;
            tempWorkspaceById[ws.id] = unified;
        }

        // Update workspaces.values to mimic Hyprland.workspaces
        workspaces.values = unifiedWorkspaces;
        workspaceById = tempWorkspaceById;
        workspaceIds = unifiedWorkspaces.map(ws => ws.id);

        // Count windows per workspace
        for (const ws of unifiedWorkspaces) {
            ws.windows = windowList.filter(w => {
                const winWsId = tempWorkspaceById[w.workspace_id]?.id;
                return winWsId === ws.id;
            }).length;
        }

        // Find active workspace
        const focusedWs = unifiedWorkspaces.find(ws => ws.is_focused);
        activeWorkspace = focusedWs ?? null;

        // Update monitor workspaces
        updateMonitorWorkspaces();

        // Update window workspace references
        updateWindowWorkspaceReferences();
    }

    function updateWindowWorkspaceReferences() {
        const updatedWindows = [];
        for (const win of windowList) {
            const updatedWin = {};
            for (const prop in win) {
                updatedWin[prop] = win[prop];
            }

            // Find the unified workspace by niri workspace_id
            const ws = workspaceById[win.workspace_id];
            if (ws) {
                updatedWin.workspace = {
                    id: ws.id
                };
            } else {
                // Fallback
                updatedWin.workspace = {
                    id: 1
                };
            }

            updatedWindows.push(updatedWin);
        }
        windowList = updatedWindows;

        // Update the byAddress map too
        const tempWinByAddress = {};
        for (const win of updatedWindows) {
            tempWinByAddress[win.id] = win;
        }
        windowByAddress = tempWinByAddress;
    }

    function processNiriMonitors(outputsData) {
        const monitorArray = [];

        for (const outputName in outputsData) {
            const output = outputsData[outputName];
            const monitor = {
                id: output.id ?? 0,
                name: outputName,
                description: output.name ?? outputName,
                make: output.make ?? "",
                model: output.model ?? "",
                width: output.logical?.width ?? output.physical?.width ?? 0,
                height: output.logical?.height ?? output.physical?.height ?? 0,
                x: output.logical?.x ?? 0,
                y: output.logical?.y ?? 0,
                scale: output.logical?.scale ?? 1.0,
                refreshRate: output.current_mode?.refresh ?? 60.0,
                transform: 0,
                activeWorkspace: null,
                focused: output.focused ?? false
            };
            monitorArray.push(monitor);
        }

        monitors = monitorArray;
        updateMonitorWorkspaces();
    }

    function updateMonitorWorkspaces() {
        const updatedMonitors = [];
        for (const m of monitors) {
            const updatedMonitor = {};
            for (const prop in m) {
                updatedMonitor[prop] = m[prop];
            }

            const ws = workspaces.values.find(w => w.monitor === m.name && (w.is_active || w.is_focused));
            updatedMonitor.activeWorkspace = ws ?? null;

            updatedMonitors.push(updatedMonitor);
        }
        monitors = updatedMonitors;
    }

    // ========== UNIFIED API ==========

    function dispatch(command) {
        if (isHyprland) {
            return Hyprland.dispatch(command);
        } else if (isNiri) {
            // Parse hyprland-style commands and convert to niri
            if (command.startsWith("workspace r+1")) {
                return moveWorkspaceDown();
            } else if (command.startsWith("workspace r-1")) {
                return moveWorkspaceUp();
            } else if (command.startsWith("workspace ")) {
                const match = command.match(/workspace (\d+)/);
                if (match) {
                    return switchToWorkspace(parseInt(match[1]) - 1);
                }
            } else if (command.startsWith("togglespecialworkspace")) {
                return toggleOverview();
            }
            console.warn("CompositorService: Unknown command for niri:", command);
            return false;
        }
        return false;
    }

    function monitorFor(screen) {
        if (isHyprland) {
            return Hyprland.monitorFor(screen);
        } else if (isNiri) {
            if (!screen)
                return null;

            // Find monitor by screen name
            const monitor = monitors.find(m => m.name === screen.name);
            if (!monitor)
                return null;

            // Return a Hyprland-compatible monitor object
            return {
                name: monitor.name,
                description: monitor.description,
                make: monitor.make,
                model: monitor.model,
                width: monitor.width,
                height: monitor.height,
                x: monitor.x,
                y: monitor.y,
                scale: monitor.scale,
                refreshRate: monitor.refreshRate,
                activeWorkspace: monitor.activeWorkspace
            };
        }
        return null;
    }

    // Niri-specific command execution
    function executeNiriCommand(args) {
        if (!isNiri)
            return false;
        Quickshell.execDetached({
            command: args
        });
        return true;
    }

    function moveWorkspaceDown() {
        if (isNiri) {
            executeNiriCommand(["niri", "msg", "action", "focus-workspace-down"]);
            Qt.callLater(() => niriWorkspacesProcess.running = true);
            return true;
        }
        return false;
    }

    function moveWorkspaceUp() {
        if (isNiri) {
            executeNiriCommand(["niri", "msg", "action", "focus-workspace-up"]);
            Qt.callLater(() => niriWorkspacesProcess.running = true);
            return true;
        }
        return false;
    }

    function switchToWorkspace(workspaceIndex) {
        if (isNiri) {
            executeNiriCommand(["niri", "msg", "action", "focus-workspace", workspaceIndex.toString()]);
            Qt.callLater(() => niriWorkspacesProcess.running = true);
            return true;
        }
        return false;
    }

    function toggleOverview() {
        if (isNiri) {
            return executeNiriCommand(["niri", "msg", "action", "toggle-overview"]);
        }
        return false;
    }
}
