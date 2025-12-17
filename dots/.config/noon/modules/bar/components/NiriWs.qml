import qs
import qs.store
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects

Item {
    required property var bar
    property bool borderless: !Mem.options.bar.appearance.modulesBg
    readonly property var monitor: {
        // Find monitor data for this screen
        if (!Compositor.monitors || Compositor.monitors.length === 0)
            return null
        return Compositor.monitors.find(m => m.name === bar.screen?.name) ?? null
    }
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    readonly property int workspaceGroup: {
        const activeWs = Compositor.activeWorkspace
        if (!activeWs) return 0
        return Math.floor((activeWs.id - 1) / 10)
    }
    property color activeColor: Colors.colOnSecondaryContainer
    property color inactiveColor: ColorUtils.transparentize(Colors.colOnSecondaryContainer, 0.5)
    property list<bool> workspaceOccupied: []
    property int widgetPadding: 8

    // Orientation support
    property bool vertical: false

    // Progress bar dimensions
    property real progressBarWidth: 100
    property real progressBarHeight: (BarData.currentBarExclusiveSize * 0.6) * BarData.barPadding


    // Maximum workspaces to show
    property int maxWorkspaces: 8

    property int workspaceIndexInGroup: {
        const activeWs = Compositor.activeWorkspace
        if (!activeWs) return 0
        return (activeWs.id - 1) % maxWorkspaces
    }

    // Function to update workspaceOccupied
    function updateWorkspaceOccupied() {
        workspaceOccupied = Array.from({
            length: maxWorkspaces
        }, (_, i) => {
            // return Compositor.workspaces.some(ws => (ws.idx + 1) === workspaceGroup * maxWorkspaces + i + 1)
        })
    }

    // Initialize workspaceOccupied when the component is created
    Component.onCompleted: updateWorkspaceOccupied()

    // Listen for changes in Compositor.workspaces
    Connections {
        target: NiriService
        function onWorkspacesChanged() {
            updateWorkspaceOccupied()
        }
        function onActiveWorkspaceChanged() {
            updateWorkspaceOccupied()
        }
    }

    implicitWidth: vertical ? parent.width * BarData.barPadding : (progressBarWidth + widgetPadding * 2)
    implicitHeight: vertical ? (progressBarWidth + widgetPadding * 2) : parent.height * BarData.barPadding

    WheelHandler {
        onWheel: event => {
            if (event.angleDelta.y < 0)
                Compositor.moveWorkspaceDown()
            else if (event.angleDelta.y > 0)
                Compositor.moveWorkspaceUp()
        }
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.BackButton
        onPressed: event => {
            if (event.button === Qt.BackButton) {
                // Niri doesn't have special workspaces, could use overview instead
                Compositor.toggleOverview()
            }
        }
    }

    // Progress bar workspace indicator
    Item {
        anchors.centerIn: parent
        width: vertical ? progressBarHeight : progressBarWidth
        height: vertical ? progressBarWidth : progressBarHeight

        ClippedProgressBar {
            id: workspaceProgress
            anchors.fill: parent

            // Set vertical mode
            vertical: parent.parent.vertical

            // Calculate progress based on active workspace within the group
            value: (workspaceIndexInGroup + 1) / maxWorkspaces

            valueBarWidth: vertical ? progressBarHeight : progressBarWidth
            valueBarHeight: vertical ? progressBarWidth : progressBarHeight
            highlightColor: activeColor
            trackColor: inactiveColor

            // Display current workspace number
            text: "" //(workspaceIndexInGroup + 1).toString()

            font {
                pixelSize: 13
                weight: Font.DemiBold
            }

            // Smooth animation for value changes
            Behavior on value {
                Anim {}
            }
        }

        // Click handler for different workspace sections
        Repeater {
            model: maxWorkspaces

            MouseArea {
                property int workspaceValue: workspaceGroup * maxWorkspaces + index + 1

                x: vertical ? 0 : ((progressBarWidth / maxWorkspaces) * index)
                y: vertical ? ((progressBarWidth / maxWorkspaces) * (maxWorkspaces - index - 1)) : 0
                width: vertical ? progressBarHeight : (progressBarWidth / maxWorkspaces)
                height: vertical ? (progressBarWidth / maxWorkspaces) : progressBarHeight

                onClicked: Compositor.switchToWorkspace(workspaceValue - 1) // Niri uses 0-based indexing
                cursorShape: Qt.PointingHandCursor

                // Visual feedback on hover
                hoverEnabled: true

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: parent.containsMouse ? ColorUtils.transparentize(activeColor, 0.3) : "transparent"
                    border.width: 1
                    radius: 9999

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150
                            easing.type: Easing.OutQuart
                        }
                    }
                }
            }
        }
    }
}
