pragma Singleton
pragma ComponentBehavior: Bound
import QtCore
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string socketPath: Quickshell.env("NIRI_SOCKET")
    readonly property bool isNiri: socketPath !== ""

    // Window data
    property var windowList: []
    property var addresses: []
    property var windowByAddress: ({})

    // Workspace data
    property var workspaces: []
    property var workspaceIds: []
    property var workspaceById: ({})
    property var activeWorkspace: null

    // Display data
    property var monitors: []
    property var layers: ({})

    function updateAll() {
        if (!isNiri)
            return

        windowsProcess.running = true
        workspacesProcess.running = true
        outputsProcess.running = true
    }

    function biggestWindowForWorkspace(workspaceId) {
        const windowsInWorkspace = windowList.filter(w => w.workspace_id === workspaceId)
        return windowsInWorkspace.reduce((maxWin, win) => {
            const maxArea = (maxWin?.size?.[0] ?? 0) * (maxWin?.size?.[1] ?? 0)
            const winArea = (win?.size?.[0] ?? 0) * (win?.size?.[1] ?? 0)
            return winArea > maxArea ? win : maxWin
        }, null)
    }

    Component.onCompleted: {
        updateAll()
    }

    // Polling timer for updates (faster than before - 500ms)
    Timer {
        property int updateCounter: 0
        id: updateTimer
        interval: 100
        repeat: true
        running: root.isNiri
        triggeredOnStart: false
        onTriggered: {
            workspacesProcess.running = true
            if (updateCounter % 2 === 0) {
                windowsProcess.running = true
            }
        updateCounter++
        }

    }

    // Separate processes for each data type
    Process {
        id: windowsProcess
        command: ["niri", "msg", "-j", "windows"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                try {
                    const windowsData = JSON.parse(data)
                    processWindows(windowsData)
                } catch (e) {
                    console.warn("NiriService: Failed to parse windows:", e)
                }
            }
        }
    }

    Process {
        id: workspacesProcess
        command: ["niri", "msg", "-j", "workspaces"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                try {
                    const workspacesData = JSON.parse(data)
                    processWorkspaces(workspacesData)
                } catch (e) {
                    console.warn("NiriService: Failed to parse workspaces:", e)
                }
            }
        }
    }

    Process {
        id: outputsProcess
        command: ["niri", "msg", "-j", "outputs"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                try {
                    const outputsData = JSON.parse(data)
                    processMonitors(outputsData)
                } catch (e) {
                    console.warn("NiriService: Failed to parse outputs:", e)
                }
            }
        }
    }

    function processWindows(windowsData) {
        windowList = windowsData
        const tempWinByAddress = {}

        for (const win of windowsData) {
            tempWinByAddress[win.id] = win
        }

        windowByAddress = tempWinByAddress
        addresses = windowsData.map(win => win.id)
    }

    function processMonitors(outputsData) {
        const monitorArray = []

        for (const outputName in outputsData) {
            const output = outputsData[outputName]
            monitorArray.push({
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
                activeWorkspace: output.current_workspace ?? null,
                focused: output.focused ?? false
            })
        }

        monitors = monitorArray
    }

    function processWorkspaces(workspacesData) {
        workspaces = workspacesData
        const tempWorkspaceById = {}

        for (const ws of workspacesData) {
            const hyprlandWs = {
                id: ws.idx + 1,
                name: (ws.idx + 1).toString(),
                monitor: ws.output ?? "",
                windows: 0,
                hasfullscreen: false,
                lastwindow: ws.active_window_id ?? null,
                lastwindowtitle: "",
                idx: ws.idx
            }

            tempWorkspaceById[hyprlandWs.id] = hyprlandWs

            if (ws.is_focused) {
                activeWorkspace = hyprlandWs
            }
        }

        workspaceById = tempWorkspaceById
        workspaceIds = workspacesData.map(ws => ws.idx + 1)
    }

    // Command execution
    function executeCommand(args) {
        if (!isNiri) return false
        Quickshell.execDetached({
            command: args
        })
        return true
    }

    function moveWorkspaceDown() {
        executeCommand(["niri", "msg", "action", "focus-workspace-down"])
        Qt.callLater(() => workspacesProcess.running = true)
        return true
    }

    function moveWorkspaceUp() {
        executeCommand(["niri", "msg", "action", "focus-workspace-up"])
        Qt.callLater(() => workspacesProcess.running = true)
        return true
    }

    function switchToWorkspace(workspaceIndex) {
        executeCommand(["niri", "msg", "action", "focus-workspace", workspaceIndex.toString()])
        Qt.callLater(() => workspacesProcess.running = true)
        return true
    }

    function toggleOverview() {
        return executeCommand(["niri", "msg", "action", "toggle-overview"])
    }
}
