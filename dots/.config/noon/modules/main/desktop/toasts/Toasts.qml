import qs.common
import qs.common.widgets
import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Scope {
    id: notificationPopup

    Variants {
        model: MonitorsInfo.main

        StyledPanel {
            id: root
            required property var modelData
            screen: modelData
            visible: true //(GlobalStates.toasts.data.length > 0) ?? false
            name: "toasts"
            WlrLayershell.layer: WlrLayer.Overlay
            exclusiveZone: 0
            aboveWindows: true

            anchors {
                top: true
                bottom: true
                right: true
            }

            mask: Region {
                item: Rectangle {
                    color: "transparent"
                    x: listview.x
                    y: listview.y + listview.height - listview.contentHeight
                    width: listview.width
                    height: listview.contentHeight
                }
            }

            color: "transparent"
            implicitWidth: 500

            Timer {
                interval: 3000
                running: true
                onTriggered: listview.visible = true
            }

            StyledListView {
                id: listview
                visible: false
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    bottomMargin: Padding.massive
                    right: parent.right
                    margins: Padding.massive
                }
                hint: false
                popin: true
                animateMovement: true
                animateAppearance: true
                implicitWidth: Sizes.notificationPopupWidth - anchors.rightMargin * 2
                verticalLayoutDirection: ListView.BottomToTop
                model: GlobalStates.toasts.data
                spacing: Padding.normal
                delegate: Toast {
                    width: listview?.width
                }
            }
        }
    }
}
