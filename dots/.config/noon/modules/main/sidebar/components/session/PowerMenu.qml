import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets

Item {
    id: root
    
    property int buttonSize: parent.width * 0.8
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
            "c": Qt.rgba(Colors.m3.m3primary.r, Colors.m3.m3primary.g, Colors.m3.m3primary.b, 0.15),
            "hc": Qt.rgba(Colors.m3.m3primary.r, Colors.m3.m3primary.g, Colors.m3.m3primary.b, 0.25),
            "i": Colors.m3.m3primary
        },
        {
            "icon": "dark_mode",
            "tooltip": qsTr("Sleep"),
            "command": "systemctl suspend || loginctl suspend",
            "c": Qt.rgba(Colors.m3.m3tertiary.r, Colors.m3.m3tertiary.g, Colors.m3.m3tertiary.b, 0.15),
            "hc": Qt.rgba(Colors.m3.m3tertiary.r, Colors.m3.m3tertiary.g, Colors.m3.m3tertiary.b, 0.25),
            "i": Colors.m3.m3tertiary
        },
        {
            "icon": "logout",
            "tooltip": qsTr("Logout"),
            "command": "loginctl terminate-user ''",
            "c": Qt.rgba(Colors.m3.m3secondary.r, Colors.m3.m3secondary.g, Colors.m3.m3secondary.b, 0.15),
            "hc": Qt.rgba(Colors.m3.m3secondary.r, Colors.m3.m3secondary.g, Colors.m3.m3secondary.b, 0.25),
            "i": Colors.m3.m3secondary
        },
        {
            "icon": "restart_alt",
            "tooltip": qsTr("Restart"),
            "command": "reboot || loginctl reboot",
            "c": Qt.rgba(Colors.m3.m3success.r, Colors.m3.m3success.g, Colors.m3.m3success.b, 0.15),
            "hc": Qt.rgba(Colors.m3.m3success.r, Colors.m3.m3success.g, Colors.m3.m3success.b, 0.25),
            "i": Colors.m3.m3success
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
    
    ColumnLayout {
        anchors.centerIn: parent
        spacing: Padding.large
        
        Repeater {
            model: root.contentModel
            
            delegate: RippleButton {
                implicitHeight: buttonSize
                implicitWidth: buttonSize
                buttonRadius: Rounding.verylarge
                colBackground: modelData.c
                
                Symbol {
                    anchors.centerIn: parent
                    text: modelData.icon
                    color: modelData.i
                    font.pixelSize: buttonSize * 0.6
                }
                
                releaseAction: () => {
                    modelData?.command === "" ? Noon.callIpc("global lock") : Noon.execDetached(modelData.command);
                }
            }
        }
    }
}