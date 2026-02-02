import qs.common
import qs.common.widgets
import QtQuick

BarGroup {
    id: root
    property var bar

    readonly property real defaultSize: maxWorkspaces * Padding.veryhuge
    readonly property int maxWorkspaces: Mem.options.bar.workspaces.shownWs || 6
    readonly property int workspaceIndexInGroup: (MonitorsInfo.monitorFor(bar.screen).activeWorkspace?.id - 1) % maxWorkspaces

    clip: false
    implicitWidth: defaultSize
    implicitHeight: defaultSize
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.BackButton
        onWheel: event => {
            if (event.angleDelta.y < 0)
                Hyprland.dispatch(`workspace r+1`);
            else if (event.angleDelta.y > 0)
                Hyprland.dispatch(`workspace r-1`);
        }
    }

    ClippedProgressBar {
        id: workspaceProgress
        anchors.fill: parent
        anchors.margins: Padding.small
        vertical: parent.vertical
        value: (workspaceIndexInGroup + 1) / maxWorkspaces
        highlightColor: Colors.colPrimary
        trackColor: Colors.colLayer3

        Behavior on value {
            Anim {
                duration: Animations.durations.large
            }
        }
    }
}
