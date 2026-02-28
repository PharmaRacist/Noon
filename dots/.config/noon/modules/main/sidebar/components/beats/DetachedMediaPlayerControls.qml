import qs.common
import qs.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris

Item {
    id: root
    implicitHeight: 65
    readonly property var player: BeatsService.player
    readonly property QtObject colors: BeatsService.colors

    StyledRect {
        id: bg
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        implicitWidth: root.width / 1.5 < 500 ? root.width : root.width / 1.5

        color: Colors.colLayer2
        radius: Rounding.large
        enableBorders: true

        RLayout {
            clip: true
            anchors.fill: parent
            anchors.rightMargin: Padding.huge
            spacing: Padding.verysmall

            CroppedImage {
                id: cover
                Layout.fillHeight: true
                Layout.preferredWidth: height
                Layout.margins: Padding.normal
                radius: Rounding.small
                source: BeatsService.artUrl
            }

            CLayout {
                Layout.alignment: Qt.alignLeft | Qt.alignVCenter
                Layout.fillWidth: true
                Layout.maximumWidth: 300
                spacing: Padding.verysmall
                StyledText {
                    text: BeatsService.title
                    font.variableAxes: Fonts.variableAxes.title
                    color: root.colors.colOnLayer2
                    truncate: true
                    font.pixelSize: Fonts.sizes.small
                }
                StyledText {
                    text: BeatsService.artist
                    font.variableAxes: Fonts.variableAxes.main
                    color: root.colors.colSubtext
                    truncate: true
                    font.pixelSize: Fonts.sizes.verysmall
                }
            }
            Spacer {}

            RLayout {
                Layout.alignment: Qt.alignRight
                spacing: Padding.normal
                Repeater {
                    model: [
                        {
                            "icon": "skip_previous",
                            "action": () => {}
                        },
                        {
                            "icon": "keyboard_double_arrow_left",
                            "action": () => player.video.position = player.video.position - seekOffset
                        },
                        {
                            "icon": player._playing ? "pause" : "play_arrow",
                            "action": () => {
                                if (player._playing) {
                                    player.pause();
                                } else {
                                    player.play();
                                }
                            }
                        },
                        {
                            "icon": "keyboard_double_arrow_right",
                            "action": () => player.video.position = player.video.position + seekOffset
                        },
                        {
                            "icon": "skip_next",
                            "action": () => {}
                        },
                        {
                            "icon": "fullscreen",
                            "action": () => root.window.fullscreen = !root.window.fullscreen
                        }
                    ]

                    delegate: Symbol {
                        required property var modelData
                        font.pixelSize: 22
                        fill: 1
                        color:root.colors.colOnLayer2
                        text: modelData.icon
                        MouseArea {
                            anchors.fill: parent
                            onClicked: modelData.action()
                        }
                    }
                }
            }
        }
    }
}
