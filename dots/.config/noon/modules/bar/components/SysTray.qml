import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Widgets
import qs.modules.common
import qs.modules.common.widgets
import qs.store

Item {
    id: root

    required property var bar
    property int iconSize: BarData.currentBarExclusiveSize / 2.5
    property bool verticalMode: Mem.options.bar.behavior.position === "left" || Mem.options.bar.behavior.position === "right"
    implicitHeight: verticalMode ? content.implicitHeight + Padding.huge : parent.height
    implicitWidth: verticalMode ? parent.width : content.implicitWidth + Padding.huge
    GridLayout {
        id: content

        anchors.centerIn: parent
        rowSpacing: Padding.large
        columnSpacing: Padding.large

        Repeater {
            model: SystemTray.items
            Layout.row: root.verticalMode ? 1 : 0 // Shift items down in vertical mode

            SysTrayItem {
                required property SystemTrayItem modelData
                implicitHeight: implicitWidth
                implicitWidth: root.iconSize
                item: modelData
            }
        }
    }

    states: [
        State {
            when: verticalMode

            PropertyChanges {
                target: content
                rows: -1
                columns: 1
            }
        },
        State {
            when: !verticalMode

            PropertyChanges {
                target: content
                rows: 1
                columns: -1
            }
        }
    ]
}
