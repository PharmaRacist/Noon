import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.common
import qs.common.widgets
import qs.services
import "../common"

Item {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 60

    readonly property var icons_model: [
        {
            icon: "camera-photo-symbolic",
            action: () => NoonUtils.execDetached(Mem.options.apps.screenshot)
        },
        {
            icon: "emblem-system-symbolic",
            action: () => NoonUtils.callIpc("apps settings")
        },
        {
            icon: "system-lock-screen-symbolic",
            action: () => LockService.lock()
        },
        {
            icon: "system-shutdown-symbolic",
            action: () => NoonUtils.execDetached("wlogout")
        }
    ]
    RowLayout {
        anchors.fill: parent
        anchors.margins: Padding.massive
        spacing: Padding.normal

        GBattery {}
        Spacer {}

        Repeater {
            model: root.icons_model

            GButtonWithIcon {
                iconSource: modelData.icon
                onPressed:  {
                    modelData.action()
                    GlobalStates.nobuntu.db.show = false
                }
            }
        }
    }

    component GBattery: Item {
        implicitHeight: 30
        implicitWidth: content.implicitWidth + Padding.massive
        visible: BatteryService.available

        RowLayout {
            id: content
            spacing: Padding.small
            anchors.centerIn: parent

            IconImage {
                readonly property string icon: {
                    if (!BatteryService.available)
                        return "";
                    if (BatteryService.isCharging)
                        return "battery-charging-symbolic";

                    if (BatteryService.isCritical)
                        return "battery-caution-symbolic";
                    if (BatteryService.isLow)
                        return "battery-low-symbolic";

                    const p = BatteryService.percentage * 100;
                    if (p > 90)
                        return "battery-full-symbolic";
                    if (p > 60)
                        return "battery-good-symbolic";
                    if (p > 30)
                        return "battery-low-symbolic";

                    return "battery-empty-symbolic";
                }

                source: NoonUtils.iconPath(icon)
                implicitSize: 22
                visible: icon !== ""
            }

            StyledText {
                text: Math.round(100 * BatteryService.percentage) + " %"
                color: Colors.colOnLayer3
                font.family: "Roboto"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignRight | Text.AlignVCenter
            }
        }
    }
}
