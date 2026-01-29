import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common
import qs.services
import qs.common.widgets
import "./../common"

Item {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 65
    StyledRectangularShadow {
        target: bg
        intensity: 0.2
    }
    StyledRect {
        id: bg
        z: 0
        anchors.fill: parent
        radius: Rounding.verylarge
        color: "transparent"
        clip: true

        BlurImage {
            id: backdrop
            z: 1
            blur: true
            anchors.fill: parent
            source: BeatsService?.artUrl ?? ""
            tint: true
            tintColor: Colors.colScrim
            tintLevel: 0.15
        }
        RowLayout {
            id: content
            z: 2

            anchors.fill: parent
            anchors.margins: Padding.normal
            anchors.rightMargin: Padding.huge
            spacing: Padding.normal

            MusicCoverArt {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                Layout.margins: Padding.tiny
                radius: Rounding.verylarge - Padding.small
            }

            ColumnLayout {
                spacing: Padding.small
                Layout.fillWidth: true
                StyledText {
                    text: BeatsService.title
                    font {
                        pixelSize: Fonts.sizes.small
                        variableAxes: Fonts.variableAxes.title
                    }
                    truncate: true
                    Layout.fillWidth: true
                    color: Colors.colOnLayer0
                }
                StyledText {
                    text: BeatsService.artist
                    font {
                        pixelSize: Fonts.sizes.verysmall
                        variableAxes: Fonts.variableAxes.main
                    }
                    truncate: true
                    Layout.fillWidth: true
                    color: Colors.colSubtext
                }
            }
            RowLayout {
                Repeater {
                    model: [
                        {
                            "icon": "go-previous-symbolic",
                            "action": function () {
                                BeatsService.player.previous();
                            }
                        },
                        {
                            "icon": BeatsService._playing ? "media-playback-pause-symbolic" : "media-playback-start-symbolic",
                            "action": function () {
                                BeatsService.player.togglePlaying();
                            }
                        },
                        {
                            "icon": "go-next-symbolic",
                            "action": function () {
                                BeatsService.player.next();
                            }
                        }
                    ]
                    delegate: StyledIconImage {
                        required property var modelData
                        source: NoonUtils.iconPath(modelData.icon)
                        implicitSize: 20
                        MouseArea {
                            anchors.fill: parent
                            onClicked: () => modelData.action()
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
        }
    }
}
