import qs.services
import qs.common
import qs.common.widgets
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    Layout.alignment: Qt.AlignHCenter
    Layout.preferredWidth: playerSelector.width + 10
    Layout.preferredHeight: playerSelector.height + 10
    Layout.bottomMargin: -10
    radius: 15
    color: root.colors.colSecondaryContainer
    visible: BeatsService.meaningfulPlayers.length > 1
    property QtObject colors: BeatsService.colors

    function getPlayerIcon(dbus) {
        if (!dbus)
            return "music_note";
        if (dbus.includes("spotify"))
            return "queue_music";
        if (dbus.includes("firefox") || dbus.includes("chromium"))
            return "web";
        if (dbus.includes("vlc"))
            return "play_circle";
        if (dbus.includes("mpv"))
            return "video_library";
        if (dbus.includes("mpd"))
            return "library_music";
        return "music_note";
    }

    function getPlayerName(player, index) {
        return player?.identity || player?.dbusName?.replace("org.mpris.MediaPlayer2.", "") || "Player " + (index + 1);
    }

    Grid {
        id: playerSelector
        anchors.centerIn: parent
        spacing: 4
        rows: 1
        columns: BeatsService.meaningfulPlayers.length

        Repeater {
            model: BeatsService.meaningfulPlayers
            delegate: RippleButtonWithIcon {
                implicitSize: 20
                buttonRadius: Rounding.full

                readonly property bool isSelected: index === BeatsService.selectedPlayerIndex

                toggled: isSelected
                colBackground: isSelected ? root.colors.colPrimary : root.colors.colSecondaryContainer
                colBackgroundToggled: root.colors.colPrimaryActive
                colBackgroundHover: isSelected ? root.colors.colPrimaryHover : root.colors.colSecondaryContainerHover
                colRipple: isSelected ? root.colors.colPrimary : root.colors.colSecondaryContainerActive

                materialIcon: root.getPlayerIcon(modelData?.dbusName)
                iconColor: isSelected ? root.colors.colOnPrimary : root.colors.colOnSecondaryContainer

                onClicked: BeatsService.selectedPlayerIndex = index

                StyledToolTip {
                    extraVisibleCondition: hovered
                    content: root.getPlayerName(modelData, index)
                }
            }
        }
    }
}
