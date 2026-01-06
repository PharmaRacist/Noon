import "../../common"
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.common.widgets

RowLayout {
    id: root

    property var bar: parent.parent

    Layout.fillHeight: true
    spacing: XPadding.small

    Repeater {
        model: SystemTray.items

        SysTrayItem {
            required property SystemTrayItem modelData

            implicitWidth: XSizes.taskbar.trayItemSize ?? 20
            implicitHeight: XSizes.taskbar.trayItemSize ?? 20
            item: modelData
        }
    }
}
