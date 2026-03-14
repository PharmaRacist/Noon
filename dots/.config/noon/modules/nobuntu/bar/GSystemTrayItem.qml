import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.common
import qs.common.widgets

MouseArea {
    id: root
    required property SystemTrayItem item

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    implicitWidth: 22
    implicitHeight: 22

    onClicked: event => {
        if (event.button === Qt.LeftButton) {
            item.activate();
        } else if (event.button === Qt.RightButton && item.hasMenu) {
            menu.active = !menu.active;
        }
    }

    onEntered: {
        const title = item.tooltipTitle || item.title || item.id;
        tooltip.text = item.tooltipDescription ? `${title} • ${item.tooltipDescription}` : title;
    }

    Loader {
        id: menu
        active: false
        sourceComponent: SysTrayMenu {
            trayItemMenuHandle: root.item.menu

            anchor {
                item: root
                edges: Edges.Bottom
                gravity: Edges.Bottom
            }

            Component.onCompleted: open()
            onMenuClosed: menu.active = false
        }
    }

    StyledIconImage {
        id: trayIcon
        anchors.centerIn: parent
        source: root.item.icon
        implicitSize: root.implicitWidth ?? 20
    }

    PopupToolTip {
        id: tooltip
        extraVisibleCondition: root.containsMouse
        anchorEdges: Edges.Bottom
    }
}
