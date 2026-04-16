import qs.services
import qs.common
import qs.common.widgets
import qs.common.functions
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

GroupButton {
    id: root

    property var appToplevel
    property var appListRoot
    property int lastFocused: -1
    property real iconSize: Mem.options.dock.appearance.iconSize
    property real countDotWidth: 10
    property real countDotHeight: 3
    property bool appIsActive: appToplevel.toplevels.find(t => (t.activated == true)) !== undefined

    property bool isSeparator: appToplevel.appId === "SEPARATOR"
    property var desktopEntry: DesktopEntries.byId(appToplevel.appId)
    enabled: !isSeparator
    baseSize: iconSize
    width: isSeparator ? 1 : implicitWidth
    Layout.fillHeight: true
    buttonRadius: Rounding.normal
    colBackground: "transparent"
    Loader {
        active: isSeparator
        anchors {
            fill: parent
            topMargin: 6
            bottomMargin: 6
        }
        sourceComponent: DockSeparator {}
    }

    Loader {
        anchors.fill: parent
        active: appToplevel.toplevels.length > 0
        sourceComponent: MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: {
                appListRoot.lastHoveredButton = root;
                appListRoot.buttonHovered = true;
                lastFocused = appToplevel.toplevels.length - 1;
            }
            onExited: {
                if (appListRoot.lastHoveredButton === root) {
                    appListRoot.buttonHovered = false;
                }
            }
        }
    }
    releaseAction: () => {
        if (appToplevel.toplevels.find(item => item.id === appToplevel.toplevels[lastFocused].id)) {
            appToplevel.toplevels[lastFocused].activate();
            return;
        } else {
            root.desktopEntry?.execute();
            lastFocused = (lastFocused + 1) % appToplevel.toplevels.length;
        }
    }

    middleClickAction: () => {
        root.desktopEntry?.execute();
    }
    altAction: () => {
        if (Mem.states.favorites.apps.indexOf(appToplevel.appId) !== -1) {
            Mem.states.favorites.apps = Mem.states.favorites.apps.filter(id => id !== appToplevel.appId);
        } else {
            Mem.states.favorites.apps = Mem.states.favorites.apps.concat([appToplevel.appId]);
        }
    }
    contentItem: Loader {
        active: !isSeparator
        sourceComponent: Item {
            anchors.fill: parent
            Loader {
                id: iconImageLoader
                anchors.centerIn: parent
                active: !root.isSeparator
                width: root.iconSize - Padding.large
                height: root.iconSize - Padding.large
                sourceComponent: StyledIconImage {
                    id: iconImage
                    cache: false
                    source: NoonUtils.iconPath(root.desktopEntry ? (root.desktopEntry.icon || root.desktopEntry.genericIcon || "applications-system") : appToplevel.appId)
                }
            }

            RowLayout {
                spacing: 2
                height: countDotHeight
                width: countDotWidth * Math.min(appToplevel.toplevels.length, 2)

                anchors {
                    top: iconImageLoader.bottom
                    topMargin: countDotHeight
                    horizontalCenter: parent.horizontalCenter
                }
                Repeater {
                    model: Math.min(appToplevel.toplevels.length, 3)
                    delegate: StyledRect {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        required property int index
                        radius: Rounding.full
                        Layout.maximumWidth: (appToplevel.toplevels.length <= 3) ? Sizes.infinity : root.countDotHeight
                        implicitHeight: root.countDotHeight
                        color: appIsActive ? Colors.colPrimary : ColorUtils.transparentize(Colors.colOnLayer0, 0.4)
                    }
                }
            }
        }
    }
}
