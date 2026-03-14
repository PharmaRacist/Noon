import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.common
import qs.common.widgets

RowLayout {
    id: root

    property var bar
    readonly property int iconSize: 24
    spacing: Padding.tiny

    Repeater {
        model: SystemTray.items

        GSystemTrayItem {
            required property SystemTrayItem modelData

            implicitWidth: root.iconSize
            implicitHeight: root.iconSize
            item: modelData
        }
    }
}
