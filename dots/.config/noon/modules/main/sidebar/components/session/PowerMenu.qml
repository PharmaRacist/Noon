import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets

Item {
    id: root

    readonly property var contentModel: [
        {
            "icon": "lock",
            "tooltip": qsTr("Lock"),
            "command": "",
            "c": Colors.colSecondaryContainer,
            "hc": Colors.colSecondaryContainerHover,
            "i": Colors.colOnSecondaryContainer,
            "shape": "Ghostish"
        },
        {
            "icon": "arrow_warm_up",
            "tooltip": qsTr("Reboot to UEFI"),
            "command": "systemctl reboot --firmware-setup",
            "c": Qt.rgba(Colors.m3.m3primary.r, Colors.m3.m3primary.g, Colors.m3.m3primary.b, 0.15),
            "hc": Qt.rgba(Colors.m3.m3primary.r, Colors.m3.m3primary.g, Colors.m3.m3primary.b, 0.25),
            "i": Colors.m3.m3primary,
            "shape": "Cookie6Sided"
        },
        {
            "icon": "dark_mode",
            "tooltip": qsTr("Sleep"),
            "command": "systemctl suspend || loginctl suspend",
            "c": Qt.rgba(Colors.m3.m3tertiary.r, Colors.m3.m3tertiary.g, Colors.m3.m3tertiary.b, 0.15),
            "hc": Qt.rgba(Colors.m3.m3tertiary.r, Colors.m3.m3tertiary.g, Colors.m3.m3tertiary.b, 0.25),
            "i": Colors.m3.m3tertiary,
            "shape": "Clover8Leaf"
        },
        {
            "icon": "logout",
            "tooltip": qsTr("Logout"),
            "command": "loginctl terminate-user ''",
            "c": Qt.rgba(Colors.m3.m3secondary.r, Colors.m3.m3secondary.g, Colors.m3.m3secondary.b, 0.15),
            "hc": Qt.rgba(Colors.m3.m3secondary.r, Colors.m3.m3secondary.g, Colors.m3.m3secondary.b, 0.25),
            "i": Colors.m3.m3secondary,
            "shape": "PixelCircle"
        },
        {
            "icon": "restart_alt",
            "tooltip": qsTr("Restart"),
            "command": "reboot || loginctl reboot",
            "c": Qt.rgba(Colors.m3.m3success.r, Colors.m3.m3success.g, Colors.m3.m3success.b, 0.15),
            "hc": Qt.rgba(Colors.m3.m3success.r, Colors.m3.m3success.g, Colors.m3.m3success.b, 0.25),
            "i": Colors.m3.m3success,
            "shape": "Cookie9Sided"
        },
        {
            "icon": "power_settings_new",
            "tooltip": qsTr("Shutdown"),
            "command": "systemctl poweroff || loginctl poweroff",
            "c": Qt.rgba(Colors.m3.m3error.r, Colors.m3.m3error.g, Colors.m3.m3error.b, 0.15),
            "hc": Qt.rgba(Colors.m3.m3error.r, Colors.m3.m3error.g, Colors.m3.m3error.b, 0.25),
            "i": Colors.m3.m3error,
            "shape": "Bun"
        }
    ]

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Padding.large

        Repeater {
            model: root.contentModel

            delegate: MaterialShapeWrappedMaterialSymbol {
                required property var modelData
                readonly property int buttonSize: root.width * 0.86
                implicitSize: buttonSize
                color: modelData.c
                iconSize: buttonSize * 0.6
                colSymbol: modelData.i
                text: modelData.icon
                shape: eventArea.containsMouse ? MaterialShape.Shape.Cookie12Sided : MaterialShape.Shape[modelData.shape]
                fill: eventArea.containsMouse ? 1 : 0
                MouseArea {
                    id: eventArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: () => {
                        modelData?.command === "" ? NoonUtils.callIpc("global lock") : NoonUtils.execDetached(modelData.command);
                    }
                }
            }
        }
    }
}
