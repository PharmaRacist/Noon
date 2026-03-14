import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.utils

Item {
    implicitHeight: controlsRow.implicitHeight + Padding.verylarge
    implicitWidth: controlsRow.implicitWidth + Padding.verylarge
    property var panelWindow
    readonly property var controls: Mem.options.applications.windowControls
    StyledRect {
        id: bg
        color: controlsRow.children.length > 1 ? Colors.colLayer2 : "transparent"
        anchors.fill: parent
        radius: Rounding.full
        RowLayout {
            id: controlsRow
            anchors.centerIn: parent
            spacing: Padding.small
            Repeater {
                model: [
                    {
                        "icon": "collapse_content",
                        "enabled": controls.minimize,
                        "action": () => {
                            panelWindow.minimize();
                        }
                    },
                    {
                        "icon": "expand_content",
                        "enabled": controls.maximize,
                        "action": () => {
                            panelWindow.maximize();
                        }
                    },
                    {
                        "icon": "close",
                        "enabled": controls.close,
                        "action": () => {
                            panelWindow.visible = false;
                        }
                    }
                ]
                delegate: RippleButtonWithIcon {
                    required property var modelData
                    visible: modelData.enabled
                    materialIcon: modelData.icon
                    colBackground: Colors.colLayer3
                    buttonRadius: Rounding.full
                    implicitSize: 34
                    releaseAction: modelData.action
                }
            }
        }
    }
    StyledRectangularShadow {
        target: bg
        enabled: bg.color !== "transparent"
    }
}
