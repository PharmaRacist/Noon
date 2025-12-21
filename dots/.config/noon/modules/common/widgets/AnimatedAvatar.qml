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
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Item {
    id: root

    property int randomIndex: generateNewRandomIndex()

    function generateNewRandomIndex() {
        return Math.floor(Math.random() * 6) + 1;
    }

    Layout.fillWidth: false
    implicitWidth: 40
    implicitHeight: 40

    AnimatedImage {
        id: avatar

        visible: !useDistro
        cache: true
        mipmap: true
        width: root.width
        height: root.height
        source: `root:/assets/gif/avatar${randomIndex}.gif`
        speed: mouseArea.containsMouse ? 1.25 : 1

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                // Fade out, change source, then fade back in
                avatar.opacity = 0;
                fadeTimer.start();
            }

            PointingHandInteraction {
            }

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

        Behavior on opacity {
            FAnim {
            }

        }

    }

}
