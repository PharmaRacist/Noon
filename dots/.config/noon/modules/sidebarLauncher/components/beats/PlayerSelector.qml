import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets

StyledRect {
    id: root
    property int selectedPlayerIndex: MusicPlayerService.selectedPlayerIndex
    onSelectedPlayerIndexChanged:MusicPlayerService.selectedPlayerIndex = selectedPlayerIndex
    Layout.alignment: Qt.AlignHCenter
    Layout.preferredWidth: playerSelector.width + 10
    Layout.preferredHeight: playerSelector.height + 10
    Layout.bottomMargin: -10

    radius: 15
    enableShadows: true
    color: TrackColorsService.colors.colSecondaryContainer

    visible: MusicPlayerService.meaningfulPlayers.length > 1

    function iconForPlayer(dbus) {
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

    function buildTabs() {
        return MusicPlayerService.meaningfulPlayers.map((p, i) => {
            const dbus = p?.dbusName ?? "";
            return {
                name: p?.identity ?? dbus.replace("org.mpris.MediaPlayer2.", "") ?? ("Player " + (i + 1)),
                icon: iconForPlayer(dbus),
                index: i
            };
        });
    }

    Grid {
        id: playerSelector
        anchors.centerIn: parent
        spacing: 4
        rows: 1
        columns: MusicPlayerService.meaningfulPlayers.length

        Repeater {
            model: root.buildTabs()

            delegate: RippleButton {
                implicitWidth: 20
                implicitHeight: 20
                buttonRadius: 10

                property bool isSelected: modelData.index === root.selectedPlayerIndex
                colBackground: isSelected ? TrackColorsService.colors.colPrimary : TrackColorsService.colors.colSecondaryContainer
                colBackgroundHover: isSelected ? TrackColorsService.colors.colPrimaryHover : TrackColorsService.colors.colSecondaryContainerHover
                colRipple: isSelected ? TrackColorsService.colors.colPrimary : TrackColorsService.colors.colSecondaryContainerActive

                onClicked: {
                    root.selectedPlayerIndex = modelData.index;
                    Mem.states.services.mediaPlayer.selectedPlayerIndex = modelData.index;
                }

                StyledToolTip {
                    extraVisibleCondition: hovered
                    content: modelData.name
                }

                contentItem: MaterialSymbol {
                    text: modelData.icon
                    font.pixelSize: Fonts.sizes.verysmall
                    horizontalAlignment: Text.AlignHCenter
                    color: isSelected ? TrackColorsService.colors.colOnPrimary : TrackColorsService.colors.colOnSecondaryContainer
                }
            }
        }
    }
}
