import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.common.widgets

BarGroup {
    id: root
    Layout.preferredWidth: columnLayout.implicitWidth + padding
    Layout.preferredHeight: columnLayout.implicitHeight + padding
    readonly property var content: [
        {
            "icon": "colorize",
            "action": function () {
                NoonUtils.execDetached("hyprpicker -a -q");
            }
        },
        {
            "icon": "screenshot",
            "action": function () {
                ScreenShotService.takeScreenShot();
            }
        },
        {
            "icon": "dashboard",
            "action": function () {
                NoonUtils.callIpc("sidebar reveal Apps");
            }
        }
    ]

    GridLayout {
        id: columnLayout

        rows: !vertical ? 1 : 4
        columns: vertical ? 1 : 4
        columnSpacing: 4
        rowSpacing: 4
        anchors.centerIn: parent
        Repeater {
            id: repeater
            model: root.content
            delegate: RippleButtonWithIcon {
                toggled: false
                materialIcon: modelData.icon
                materialIconFill: hovered
                iconSize: Math.round(root.height * (hovered ? 0.5 : 0.45))
                implicitSize: Math.round(root.height * 0.75)
                releaseAction: () => modelData.action()
            }
        }
    }
}
