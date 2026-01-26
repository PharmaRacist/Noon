import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common
import qs.services
import qs.common.widgets
import qs.common.functions
import "./../common"

ColumnLayout {
    id: root
    spacing: Padding.verylarge
    Layout.alignment: Qt.AlignHCenter

    readonly property var pinned: Mem.states.favorites.apps ?? []
    readonly property int iconSize: 50
    readonly property var runningUnpinned: {
        const running = new Set(ToplevelManager.toplevels.values.map(t => (t.appId || "").toLowerCase()));
        const pinnedSet = new Set(pinned.map(p => (p || "").toLowerCase()));
        return Array.from(running).filter(id => id && !pinnedSet.has(id));
    }

    Repeater {
        model: {
            const items = [...root.pinned];
            if (items.length && root.runningUnpinned.length) {
                items.push("SEPARATOR");
            }
            return items.concat(root.runningUnpinned);
        }

        delegate: Loader {
            required property var modelData
            readonly property bool isSeparator: modelData === "SEPARATOR"

            visible: modelData !== ""
            Layout.alignment: Qt.AlignHCenter
            width: isSeparator ? 20 : root.iconSize
            height: isSeparator ? 1 : root.iconSize
            sourceComponent: isSeparator ? separatorComp : iconComp

            onLoaded: if (item && !isSeparator)
                item.appId = modelData
        }
    }

    Component {
        id: separatorComp
        Rectangle {
            color: Colors.colSubtext
            opacity: 0.3
            height: 1
            width: 10
        }
    }

    Component {
        id: iconComp
        Item {
            property string appId: ""
            readonly property var sessions: ToplevelManager.toplevels.values.filter(t => (t.appId || "").toLowerCase() === appId.toLowerCase())

            StyledIconImage {
                anchors.centerIn: parent
                implicitSize: Math.round(root.iconSize * 0.85)
                source: appId ? NoonUtils.iconPath(appId) : ""
            }

            ColumnLayout {
                spacing: 2
                height: parent.height * 0.6
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    leftMargin: -6
                }

                Repeater {
                    model: sessions

                    StyledRect {
                        required property var modelData

                        Layout.fillHeight: sessions.length < 5
                        width: 4
                        height: 4
                        radius: 4
                        color: (modelData.activated ?? false) ? Colors.colPrimary : Colors.colSubtext
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onPressed: event => {
                    if (event.button === Qt.LeftButton) {
                        if (sessions.length) {
                            sessions[sessions.length - 1].activate();
                        } else {
                            DesktopEntries.byId(appId).execute();
                        }
                    } else if (event.button === Qt.RightButton) {
                        contextMenu.popup();
                    }
                }
            }

            StyledMenu {
                id: contextMenu
                z: 1000
                content: {
                    const isPinned = root.pinned.includes(appId);
                    const hasSessions = sessions.length > 0;

                    return [
                        {
                            materialIcon: isPinned ? "push_pin" : "keep_off",
                            text: isPinned ? "Unpin" : "Pin",
                            action: () => {
                                let favorites = [...(Mem.states.favorites.apps ?? [])];
                                Mem.states.favorites.apps = isPinned ? favorites.filter(id => id !== appId) : [...favorites, appId];
                            }
                        },
                        {
                            materialIcon: "add",
                            text: "New Session",
                            action: () => DesktopEntries.byId(appId).execute()
                        },
                        ...(hasSessions ? [
                                {
                                    materialIcon: "visibility",
                                    text: "Focus",
                                    action: () => sessions[0].activate()
                                }
                            ] : []), ...(hasSessions ? [
                                {
                                    materialIcon: "close",
                                    text: sessions.length > 1 ? "Close All" : "Close",
                                    action: () => sessions.forEach(s => s.close())
                                }
                            ] : [])];
                }
            }

            StyledToolTip {
                extraVisibleCondition: mouseArea.containsMouse
                content: DesktopEntries.byId(appId).name
            }
        }
    }
}
