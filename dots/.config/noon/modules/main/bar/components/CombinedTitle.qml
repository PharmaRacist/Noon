import qs.services
import qs.store
import qs.common
import qs.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland

MouseArea {
    id: root
    hoverEnabled: true
    height: rotatedContainer.height
    width: BarData.currentBarExclusiveSize

    required property var bar
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(bar.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    readonly property string appId: activeWindow?.activated ? (activeWindow?.appId ?? "") : ""

    WorkspacePopup {
        hoverTarget: root
    }

    Item {
        id: rotatedContainer
        anchors.centerIn: parent
        width: nameText.implicitHeight
        height: nameText.implicitWidth
        rotation: -90
        transformOrigin: Item.Center

        StyledText {
            id: nameText
            anchors.centerIn: parent
            text: root.appId || "Desktop"
            font.variableAxes: Fonts.variableAxes.title
            font.pixelSize: BarData.currentBarExclusiveSize * BarData.barPadding / 1.5
            font.family: Fonts.family.title
            color: Colors.colOnLayer1
            elide: Text.ElideRight
            maximumLineCount: 1
            font.weight: Font.DemiBold
            animateChange: true
        }
    }
}
