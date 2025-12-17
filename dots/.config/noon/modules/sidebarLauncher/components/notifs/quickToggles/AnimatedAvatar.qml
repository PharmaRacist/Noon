import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs
import qs.modules.common

import qs.modules.common.widgets
import qs.services

Item {
    Layout.fillWidth: false
    implicitWidth: 40
    implicitHeight: 40
    property bool useDistro: false
    property int randomIndex: generateNewRandomIndex()

    function generateNewRandomIndex() {
        return Math.floor(Math.random() * 6) + 1;
    }

    CustomIcon {
        id: distroIcon
        visible: useDistro
        width: 40
        height: 40
        source: SystemInfo.distroIcon
        Layout.bottomMargin: -5
    }
    ColorOverlay {
        anchors.fill: distroIcon
        source: distroIcon
        color: Colors.m3.m3secondary
    }
    AnimatedImage {
        id: avatar
        visible: !useDistro
        cache: true
        mipmap: true
        height: 60
        width: 60
        source: `root:/assets/gif/avatar${randomIndex}.gif`
        speed: mouseArea.containsMouse ? 1.25 : 1

        Behavior on opacity {
            FAnim {}
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                // Fade out, change source, then fade back in
                avatar.opacity = 0;
                fadeTimer.start();
            }
            PointingHandInteraction {}
        }

        Timer {
            id: fadeTimer
            interval: 200
            onTriggered: {
                randomIndex = generateNewRandomIndex();
                avatar.source = `root:/assets/gif/avatar${randomIndex}.gif`;
                avatar.opacity = 1;
            }
        }
    }
}
