import qs.common
import "notification_utils.js" as NotificationUtils
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications

Rectangle {
    id: root
    property var appIcon: ""
    property var summary: ""
    property var urgency: NotificationUrgency.Normal
    property var image: ""
    property real scale: 1
    property real size: 45 * scale
    property real materialIconScale: 0.57
    property real appIconScale: 0.7
    property real smallAppIconScale: 0.49
    property real materialIconSize: size * materialIconScale
    property real appIconSize: size * appIconScale
    property real smallAppIconSize: size * smallAppIconScale

    implicitWidth: size
    implicitHeight: size
    radius: Rounding.full
    color: Colors.colSecondaryContainer

    Loader {
        anchors.fill: parent
        sourceComponent: {
            if (root.image !== "")
                return notifImageComponent;
            if (root.appIcon !== "")
                return appIconComponent;
            return materialSymbolComponent;
        }

        Component {
            id: materialSymbolComponent
            Symbol {
                anchors.fill: parent
                text: {
                    const def = NotificationUtils.findSuitableMaterialSymbol("");
                    const guessed = NotificationUtils.findSuitableMaterialSymbol(root.summary);
                    return (root.urgency === NotificationUrgency.Critical && guessed === def) ? "release_alert" : guessed;
                }
                color: root.urgency === NotificationUrgency.Critical ? ColorUtils.mix(Colors.m3.m3onSecondary, Colors.m3.m3onSecondaryContainer, 0.1) : Colors.m3.m3onSecondaryContainer
                iconSize: root.materialIconSize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Component {
            id: appIconComponent
            StyledIconImage {
                anchors.centerIn: parent
                implicitSize: root.appIconSize
                asynchronous: true
                colorize: true
                _source: root.appIcon
            }
        }

        Component {
            id: notifImageComponent

            CroppedImage {
                anchors.fill: parent
                source: root.image
                radius: Rounding.full
                asynchronous: true
            }
        }
    }
}
