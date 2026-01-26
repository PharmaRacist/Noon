import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services
import qs.store

Item {
    id: root

    readonly property string appId: GlobalStates.topLevel.appId ?? ""
    readonly property var titleSubstitutions: ({
        "org.kde.dolphin": "File Manager",
        "dev.zed.Zed": "Zed Editor",
        "hyprland-share-picker": "Screen Share",
        "org.kde.kdeconnect.app": "KDE Connect",
        "kcm_bluetooth": "Bluetooth",
        "org.kde.plasmawindowed": "KDE Window",
        "org.telegram.desktop": "Telegram"
    })
    readonly property var iconSubstitutions: ({
        "": "home",
        "org.kde.dolphin": "folder",
        "dev.zed.Zed": "code",
        "steam": "joystick",
        "lutris": "joystick",
        "heroic": "joystick",
        "wine": "joystick",
        "wine-staging": "window",
        "codium": "code",
        "zen": "globe",
        "code": "code",
        "hyprland-share-picker": "play_arrow",
        "org.telegram.desktop": "chat_bubble",
        "org.kde.kdeconnect.app": "mobile",
        "kcm_bluetooth": "bluetooth",
        "org.kde.plasmawindowed": "deployed_code",
        "foot": "terminal",
        "kitty": "terminal",
        "ghostty": "terminal",
        "alacritty": "terminal"
    })

    function getDisplayName(id) {
        if (!id)
            return "Desktop";

        return StringUtils.capitalizeFirstLetter(titleSubstitutions[id] || id);
    }

    z: 999
    height: Math.max(rotatedContainer.height, BarData.currentBarExclusiveSize * 4)
    width: BarData.currentBarExclusiveSize

    MouseArea {
        id: eventArea

        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.PointingHandCursor
    }

    WorkspacePopup {
        hoverTarget: eventArea
    }

    Item {
        id: rotatedContainer

        anchors.centerIn: parent
        width: childrenRect.implicitHeight
        height: childrenRect.implicitWidth
        rotation: -90
        transformOrigin: Item.Center

        RowLayout {
            spacing: Padding.verylarge
            anchors.centerIn: parent

            Symbol {
                id: iconText

                animateChange: true
                text: iconSubstitutions[root.appId] || "home"
                color: Colors.colOnLayer1
                font.pixelSize: Math.round(nameText.font.pixelSize * 1.25)
                fill: 1
            }

            StyledText {
                id: nameText

                text: root.getDisplayName(root.appId)
                color: Colors.colOnLayer1
                elide: Text.ElideRight
                maximumLineCount: 1
                animateChange: true

                font {
                    variableAxes: Fonts.variableAxes.title
                    pixelSize: Math.round(BarData.currentBarExclusiveSize * BarData.barPadding / 1.5)
                    family: Fonts.family.title
                    weight: Font.DemiBold
                }

            }

        }

    }

}
