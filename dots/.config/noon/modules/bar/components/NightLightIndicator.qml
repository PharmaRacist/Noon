import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs.store

MouseArea {
    id: root

    property bool verticalMode: false
    property bool expanded: false
    property bool userInteracting: false
    property bool autoRevealed: false
    property int lastScrollX: 0
    property int lastScrollY: 0
    property bool trackingScroll: false

    function triggerAutoReveal() {
        root.expanded = true;
        root.autoRevealed = true;
        if (!userInteracting)
            autoHideTimer.restart();

    }

    function restartTimeoutIfNotInteracting() {
        if (!userInteracting && autoRevealed)
            autoHideTimer.restart();

    }

    visible: NightLightService.enabled
    hoverEnabled: true
    implicitHeight: verticalMode ? visible ? content.implicitHeight + 5 : -5 : BarData.currentBarExclusiveSize
    implicitWidth: verticalMode ? BarData.currentBarExclusiveSize : content.implicitWidth
    onContainsMouseChanged: {
        userInteracting = containsMouse;
        if (containsMouse)
            autoHideTimer.stop();
        else
            restartTimeoutIfNotInteracting();
    }
    onClicked: {
        NightLightService.toggle();
        root.triggerAutoReveal();
    }

    Timer {
        id: autoHideTimer

        interval: Mem.options.osd.timeout
        repeat: false
        running: false
        onTriggered: {
            if (!root.userInteracting && root.autoRevealed) {
                root.expanded = false;
                root.autoRevealed = false;
            } else {
                restart();
            }
        }
    }

    WheelHandler {
        onWheel: (event) => {
            const step = 100;
            let newTemp = NightLightService.temperature;
            if (event.angleDelta.y > 0)
                newTemp = Math.min(6500, newTemp + step);
            else if (event.angleDelta.y < 0)
                newTemp = Math.max(3000, newTemp - step);
            NightLightService.setTemperature(newTemp);
            root.lastScrollX = event.x;
            root.lastScrollY = event.y;
            root.trackingScroll = true;
            root.userInteracting = true;
            root.triggerAutoReveal();
            autoHideTimer.stop();
        }
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    Connections {
        function onEnabledChanged() {
            root.triggerAutoReveal();
        }

        function onTemperatureChanged() {
            root.triggerAutoReveal();
        }

        target: NightLightService
    }

    GridLayout {
        id: content

        anchors.fill: parent
        rows: verticalMode ? 2 : 1
        columns: verticalMode ? 1 : 2

        Revealer {
            id: revealer

            reveal: root.containsMouse || root.expanded
            vertical: root.verticalMode
            Layout.alignment: Qt.AlignHCenter

            ClippedProgressBar {
                visible: parent.reveal
                anchors.centerIn: parent
                vertical: root.verticalMode
                value: (NightLightService.temperature - 3000) / (6500 - 3000)
                valueBarHeight: 50
                valueBarWidth: (BarData.currentBarExclusiveSize * 0.55) * BarData.barPadding
                text: ""
                font.pixelSize: 13
                font.weight: Font.DemiBold

                Behavior on value {
                    Anim {
                    }

                }

            }

        }

        MaterialSymbol {
            fill: 1
            font.family: revealer.reveal ? Fonts.family.main : Fonts.family.iconMaterial
            text: revealer.reveal ? Math.round(NightLightService.temperature / 100) : (NightLightService.enabled ? "nightlight" : "dark_mode")
            font.pixelSize: revealer.reveal ? (verticalMode ? Fonts.sizes.small : Fonts.sizes.normal) : BarData.currentBarExclusiveSize / 2.2
            color: Colors.colOnLayer1
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

    }

}
