import QtQuick
import QtQuick.Layouts
import "dialogs"
import "notifications"
import qs.common
import qs.common.widgets

Item {
    id: root

    readonly property var dialogs: {
        "network": {
            component: "WifiDialog",
            active: GlobalStates.main.dialogs.showWifiDialog
        },
        "recording": {
            component: "RecordingDialog",
            active: GlobalStates.main.dialogs.showRecordingDialog
        },
        "kdeConnect": {
            component: "KdeConnectDialog",
            active: GlobalStates.main.dialogs.showKdeConnectDialog
        },
        "caffaine": {
            component: "CaffaineDialog",
            active: GlobalStates.main.dialogs.showCaffaineDialog
        },
        "bluetooth": {
            component: "BluetoothDialog",
            active: GlobalStates.main.dialogs.showBluetoothDialog
        },
        "appearance": {
            component: "AppearanceDialog",
            active: GlobalStates.main.dialogs.showAppearanceDialog
        },
        "transparency": {
            component: "TransparencyDialog",
            active: GlobalStates.main.dialogs.showTransparencyDialog
        },
        "temp": {
            component: "TempDialog",
            active: GlobalStates.main.dialogs.showTempDialog
        }
    }
    readonly property bool hasActiveDialog: {
        for (let key in dialogs) {
            if (dialogs[key].active)
                return true;
        }
        return false;
    }

    readonly property var activeDialog: {
        for (let key in dialogs) {
            if (dialogs[key].active) {
                let dialog = dialogs[key];
                return {
                    key: key,
                    component: dialog.component,
                    active: dialog.active
                };
            }
        }
        return null;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Padding.normal

        UpperWidgetGroup {}

        NotificationList {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    StyledLoader {
        id: dialogLoader
        anchors.fill: parent
        active: root.hasActiveDialog
        source: root.activeDialog ? sanitizeSource("dialogs/", root.activeDialog.component) : ""
        opacity: root.hasActiveDialog ? 1 : 0

        onLoaded: if (ready && root.activeDialog) {
            item.show = Qt.binding(() => root.hasActiveDialog);
        }
    }
}
