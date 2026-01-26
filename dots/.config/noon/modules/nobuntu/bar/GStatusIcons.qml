import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.common
import qs.common.widgets
import qs.services
import "../common"

StyledRect {
    readonly property real iconSize: 20

    implicitHeight: Math.round(parent.height * 0.75)
    implicitWidth: layout.implicitWidth + Padding.large * 2
    anchors.right: parent.right
    anchors.rightMargin: Padding.verylarge
    anchors.verticalCenter: parent.verticalCenter
    radius: Rounding.large

    color: {
        if (_event_area.pressed)
            Colors.colLayer0Active;
        else if (_event_area.containsMouse)
            Colors.colLayer0Hover;
        else
            "transparent";
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: Padding.normal

        Repeater {
            model: [
                {
                    show: AudioService.sink?.audio?.muted ?? false,
                    icon: "audio-volume-muted",
                    cmd: null
                },
                {
                    show: AudioService.source?.audio?.muted ?? false,
                    icon: "microphone-sensitivity-muted",
                    cmd: null
                },
                {
                    show: BluetoothService.available,
                    icon: getBtIcon(),
                    cmd: null
                },
                {
                    show: true,
                    icon: getNetIcon(),
                    cmd: Mem.options.apps.networkEthernet
                }
            ]

            IconImage {
                visible: modelData.show
                source: NoonUtils.iconPath(modelData.icon)
                implicitSize: iconSize

                MouseArea {
                    anchors.fill: parent
                    enabled: !!modelData.cmd
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NoonUtils.execDetached(modelData.cmd)
                }
            }
        }
        RowLayout {
            visible: BatteryService.available
            spacing: Padding.tiny
            IconImage {
                source: NoonUtils.iconPath(getBatteryIcon())
                implicitSize: iconSize
            }
            StyledText {
                text: BatteryService.percentage * 100 + " %"
                font {
                    family: "Roboto"
                    weight: Font.DemiBold
                    pointSize: 10
                }
            }
        }
    }

    MouseArea {
        id: _event_area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: NoonUtils.callIpc("nobuntu toggle_db")
    }

    function getNetIcon() {
        if ((NetworkService.networkName || "") !== "" && NetworkService.networkName !== "lo") {
            const s = NetworkService.networkStrength ?? 0;
            if (s > 80)
                return "network-wireless-signal-excellent";
            if (s > 60)
                return "network-wireless-signal-good";
            if (s > 40)
                return "network-wireless-signal-ok";
            if (s > 20)
                return "network-wireless-signal-weak";
            return "network-wireless-signal-none";
        }
        return (NetworkInformation.TransportMedium?.Ethernet) ? "network-connected" : "network-wireless-offline";
    }

    function getBtIcon() {
        if (BluetoothService.bluetoothConnected)
            return "bluetooth-active";
        return BluetoothService.bluetoothEnabled ? "bluetooth" : "bluetooth-disabled";
    }
    function getBatteryIcon() {
        if (!BatteryService.available)
            return "";

        const p = BatteryService.percentage * 100;
        const charging = BatteryService.charging;

        let icon = "";

        if (p >= 95)
            icon = "battery-full";
        else if (p >= 80)
            icon = "battery-level-90";
        else if (p >= 60)
            icon = "battery-level-80";
        else if (p >= 40)
            icon = "battery-level-50";
        else if (p >= 10)
            icon = "battery-level-20";
        else
            icon = "battery-caution";

        if (charging) {
            return `${icon}-charging-symbolic`;
        }

        return icon;
    }
}
