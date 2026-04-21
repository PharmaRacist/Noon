import qs.services
import qs.common
import qs.common.widgets
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    Layout.alignment: Qt.AlignHCenter
    Layout.preferredWidth: playerSelector?.width + Padding.veryhuge
    Layout.preferredHeight: 36
    Layout.bottomMargin: -10
    radius: Rounding.full
    color: root.colors.colLayer2
    visible: repeater.count > 1
    property QtObject colors: BeatsService.colors

    function getPlayerIcon(dbus) {
        if (!dbus)
            return "music_note";
        const dic = {
            "spotify": "queue_music",
            "firefox": "web",
            "vlc": "play_circle",
            "mpv": "video_library"
        };
        for (const key of Object.keys(dic)) {
            if (dbus.includes(key))
                return dic[key];
        }
        return "music_note";
    }

    function getPlayerName(player, index) {
        return player?.identity || player?.dbusName?.replace("org.mpris.MediaPlayer2.", "") || "Player " + (index + 1);
    }
    Rectangle {
        id: activeIndicator
        z: 1
        height: 20
        anchors.verticalCenter: parent.verticalCenter
        radius: Rounding.full
        color: colors.colPrimary

        readonly property int selectedIndex: BeatsService?.selectedPlayerIndex ?? 0
        readonly property var selectedItem: repeater.itemAt(selectedIndex)

        x: (playerSelector?.x ?? 0) + (selectedItem?.x ?? 0)
        width: 20

        Behavior on x {
            Anim {}
        }

        SequentialAnimation {
            id: stretchAnim
            Anim {
                target: activeIndicator
                property: "width"
                to: 32
                duration: Animations.durations.verysmall
            }
            Anim {
                target: activeIndicator
                property: "width"
                to: 20
                duration: Animations.durations.large
            }
        }

        onSelectedIndexChanged: stretchAnim.restart()
    }
    RLayout {
        id: playerSelector
        anchors.centerIn: parent
        z: 2
        Repeater {
            id: repeater
            model: BeatsService.meaningfulPlayers
            delegate: Item {
                id: symbolItem
                required property var modelData
                required property int index
                readonly property bool isSelected: index === BeatsService.selectedPlayerIndex
                height: 20
                width: 20
                Symbol {
                    id: symbol
                    anchors.centerIn: parent
                    fill: 1
                    font.pixelSize: 16
                    text: root.getPlayerIcon(modelData?.dbusName)
                    color: symbolItem.isSelected ? root.colors.colOnPrimary : root.colors.colOnLayer2
                }
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: BeatsService.selectedPlayerIndex = index
                    StyledToolTip {
                        extraVisibleCondition: parent.containsMouse
                        content: root.getPlayerName(modelData, index)
                    }
                }
            }
        }
    }
}
