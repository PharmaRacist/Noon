import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.common
import qs.common.widgets

Item {
    id: root

    property int buttonSize: 45
    property bool fillHeight: false
    property int buttonRadius: Rounding.verylarge
    property bool verticalMode: false
    property var contentModel: [
        {
            "icon": "lock",
            "tooltip": qsTr("Lock"),
            "command": "",
            "c": Colors.colSecondaryContainer,
            "hc": Colors.colSecondaryContainerHover,
            "i": Colors.colOnSecondaryContainer
        },
        {
            "icon": "arrow_warm_up",
            "tooltip": qsTr("Reboot to UEFI"),
            "command": "systemctl reboot --firmware-setup",
            "c": Qt.rgba(Colors.m3.m3error.r, Colors.m3.m3error.g, Colors.m3.m3error.b, 0.15),
            "hc": Qt.rgba(Colors.m3.m3error.r, Colors.m3.m3error.g, Colors.m3.m3error.b, 0.25),
            "i": Colors.m3.m3error
        },
        {
            "icon": "dark_mode",
            "tooltip": qsTr("Sleep"),
            "command": "systemctl suspend || loginctl suspend",
            "c": Colors.colLayer2,
            "hc": Colors.colLayer2Hover,
            "i": Colors.colOnLayer2
        },
        {
            "icon": "logout",
            "tooltip": qsTr("Logout"),
            "command": "loginctl terminate-user ''",
            "c": Qt.rgba(Colors.m3.term11.r, Colors.m3.term11.g, Colors.m3.term11.b, 0.15),
            "hc": Qt.rgba(Colors.m3.term11.r, Colors.m3.term11.g, Colors.m3.term11.b, 0.25),
            "i": Colors.m3.term11
        },
        {
            "icon": "restart_alt",
            "tooltip": qsTr("Restart"),
            "command": "reboot || loginctl reboot",
            "c": Qt.rgba(Colors.m3.term3.r, Colors.m3.term3.g, Colors.m3.term3.b, 0.15),
            "hc": Qt.rgba(Colors.m3.term3.r, Colors.m3.term3.g, Colors.m3.term3.b, 0.25),
            "i": Colors.m3.term3
        },
        {
            "icon": "power_settings_new",
            "tooltip": qsTr("Shutdown"),
            "command": "systemctl poweroff || loginctl poweroff",
            "c": Qt.rgba(Colors.m3.m3error.r, Colors.m3.m3error.g, Colors.m3.m3error.b, 0.15),
            "hc": Qt.rgba(Colors.m3.m3error.r, Colors.m3.m3error.g, Colors.m3.m3error.b, 0.25),
            "i": Colors.m3.m3error
        }
    ]
    // Single layout component that adapts based on verticalMode
    GridLayout {
        anchors.centerIn: parent
        columns: verticalMode ? 1 : contentModel.length
        rows: verticalMode ? contentModel.length : 1
        rowSpacing: Padding.large
        Repeater {
            model: root.contentModel

            delegate: Item {
                id: buttonContainer

                property bool hovered: false

                Layout.preferredWidth: buttonSize
                Layout.minimumHeight: buttonSize
                Layout.fillHeight: root.fillHeight

                RippleButton {
                    implicitHeight: buttonSize
                    implicitWidth: buttonSize
                    buttonRadius: Rounding.verylarge
                    colBackground: modelData.c
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: modelData.icon
                        color: modelData.i
                        font.pixelSize: buttonSize * 0.6
                        y: hovered ? -4 : 0

                        Behavior on y {
                            Anim {}
                        }
                    }

                    releaseAction: function () {
                        modelData?.command === "" ? Noon.callIpc("global lock") : Noon.exec(modelData.command);
                    }
                }
            }
        }
    }
}
