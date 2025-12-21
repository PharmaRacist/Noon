import qs.modules.bar.components as Components
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import qs.store
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import Quickshell.Hyprland

Rectangle {
    id: root
    readonly property bool bottomMode: Mem.options.bar.behavior.position === "bottom"
    readonly property bool shouldShow: Screen.width > 1080 ?? false
    readonly property int mode: Mem.options.bar.appearance.mode
    property var barRoot
    anchors.fill: parent

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.rightMargin: Rounding.verylarge + Sizes.hyprlandGapsOut
    anchors.leftMargin: anchors.rightMargin

    color: Colors.colLayer0
    topLeftRadius: bottomMode ? mode !== 0 ? Rounding.verylarge : 0 : 0
    topRightRadius: bottomMode ? mode !== 0 ? Rounding.verylarge : 0 : 0
    bottomRightRadius: !bottomMode ? mode !== 0 ? Rounding.verylarge : 0 : 0
    bottomLeftRadius: !bottomMode ? mode !== 0 ? Rounding.verylarge : 0 : 0
    Loader {
        id: visualizerLoader
        anchors.fill: parent
        active: Mem.options.bar.modules.visualizer ?? false
        sourceComponent: Visualizer {
            active: visualizerLoader.active
        }
    }

    RowLayout {
        spacing: 10
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 20
        }

        Components.StartButton {
            Layout.bottomMargin: -3
        }

        VerticalSeparator {
            Layout.topMargin: 10
            Layout.bottomMargin: 10
        }

        Loader {
            id: leftLoader
            width: 120
            height: 50
            sourceComponent: activeWindowComponent
            visible: root.shouldShow
            MouseArea {
                anchors.fill: parent
                onReleased: {
                    if (leftLoader.sourceComponent === activeWindowComponent) {
                        leftLoader.sourceComponent = gnomeWsComponent;
                    } else {
                        leftLoader.sourceComponent = activeWindowComponent;
                    }
                }
            }
            Component {
                id: gnomeWsComponent
                Components.GnomeWs {
                    id: gnomeWs
                    anchors.fill: parent
                    bar: barRoot
                }
            }
            Component {
                id: activeWindowComponent
                Components.ActiveWindow {
                    id: activeWin
                    anchors.fill: parent
                    bar: barRoot
                }
            }
        }
    }

    // ─────── Center Taskbar ───────
    Components.TaskBar {
        id: taskBar
        anchors.centerIn: parent
    }

    // ─────── Right Layout ───────
    RowLayout {
        implicitHeight: BarData.currentBarSize
        spacing: 20
        anchors {
            right: parent.right
            rightMargin: 20
            verticalCenter: parent.verticalCenter
        }

        Components.SysTray {
            visible: root.shouldShow
            bar: barRoot
        }
        Components.Media {
            visible: shouldShow
            opacity: MprisController.activePlayer?.trackTitle?.length > 0 ? 1 : 0
            Layout.minimumWidth: 200
            bordered: false
            Behavior on opacity {
                Anim {}
            }
        }
        Item {
            visible: root.shouldShow
            implicitWidth: statusIcons.implicitWidth
            implicitHeight: statusIcons.implicitHeight

            Components.StatusIcons {
                id: statusIcons
                anchors.fill: parent
            }
        }

        Components.GnomeClock {}
    }
    // Left corner
    RoundCorner {
        id: leftCorner
        visible: mode === 2
        size: Rounding.large
        color: root.color

        states: [
            State {
                name: "top"
                when: !root.bottomMode
                PropertyChanges {
                    target: leftCorner
                    corner: cornerEnum.topLeft
                }
                AnchorChanges {
                    target: leftCorner
                    anchors.top: parent.top
                    anchors.bottom: undefined
                    anchors.left: root.right
                }
            },
            State {
                name: "bottom"
                when: root.bottomMode
                PropertyChanges {
                    target: leftCorner
                    corner: cornerEnum.bottomLeft
                }
                AnchorChanges {
                    target: leftCorner
                    anchors.top: undefined
                    anchors.bottom: root.bottom
                    anchors.left: root.right
                }
            }
        ]
    }

    // Right corner
    RoundCorner {
        id: rightCorner
        visible: mode === 2
        size: Rounding.large
        states: [
            State {
                name: "top"
                when: !root.bottomMode
                PropertyChanges {
                    target: rightCorner
                    corner: cornerEnum.topRight
                }
                AnchorChanges {
                    target: rightCorner
                    anchors.top: parent.top
                    anchors.bottom: undefined
                    anchors.right: root.left
                }
            },
            State {
                name: "bottom"
                when: root.bottomMode
                PropertyChanges {
                    target: rightCorner
                    corner: cornerEnum.bottomRight
                }
                AnchorChanges {
                    target: rightCorner
                    anchors.top: undefined
                    anchors.bottom: root.bottom
                    anchors.right: root.left
                }
            }
        ]
    }
}
