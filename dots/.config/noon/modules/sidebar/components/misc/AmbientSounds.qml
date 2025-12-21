import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Item {
    property int gridColumns: 1

    // Inline component for sound item containers
    component SoundItemContainer: StyledRect {
        property string soundId
        property real soundVolume
        property bool playerPlaying: false
        property bool effectivePlaying: false
        property var soundInfo
        property bool isMaster: false
        property bool isActive: false

        Layout.fillWidth: true
        Layout.preferredHeight: 64
        color: Colors.colLayer1
        radius: Rounding.normal
        clip: true
        z: 0

        RowLayout {
            anchors.fill: parent

            // Icon column
            Rectangle {
                Layout.preferredWidth: 64
                Layout.fillHeight: true
                color: Colors.colPrimary

                ColumnLayout {
                    anchors.fill: parent
                    spacing: -Padding.large

                    MaterialSymbol {
                        text: isMaster ? "tune" : (soundInfo?.icon ?? "music_note")
                        font.pixelSize: 24
                        Layout.alignment: Qt.AlignCenter
                        color: Colors.colOnPrimary
                        fill: 1
                    }

                    StyledText {
                        text: isMaster ? "tune" : (soundInfo?.name ?? "")
                        Layout.alignment: Qt.AlignCenter
                        font.pixelSize: Fonts.sizes.verysmall
                        font.weight: 600
                        color: Colors.colOnPrimary
                        elide: Text.ElideRight
                        Layout.maximumWidth: parent.width - Padding.large
                        wrapMode: Text.Wrap
                        maximumLineCount: 1
                    }
                }
            }

            // Controls column
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: Padding.normal
                spacing: Padding.large

                StyledSlider {
                    id: slider
                    Layout.fillWidth: true
                    from: 0
                    to: 1
                    value: soundVolume
                    highlightColor: Colors.colPrimary
                    trackColor: Colors.colPrimaryContainer
                    handleColor: Colors.colOnPrimaryContainer

                    onMoved: {
                        if (isMaster) {
                            AmbientSoundsService.masterVolume = value;
                        } else {
                            AmbientSoundsService.setSoundVolume(soundId, value);
                        }
                    }

                    onValueChanged: {
                        if (Math.abs(value - soundVolume) > 0.001) {
                            if (isMaster) {
                                AmbientSoundsService.masterVolume = value;
                            } else {
                                AmbientSoundsService.setSoundVolume(soundId, value);
                            }
                        }
                    }
                }

                // Play/Pause button (only for non-master)
                RippleButtonWithIcon {
                    visible: !isMaster
                    materialIcon: playerPlaying ? "pause" : "play_arrow"
                    onClicked: {
                        if (playerPlaying) {
                            AmbientSoundsService.activeSounds[soundId].player.pause();
                        } else {
                            AmbientSoundsService.activeSounds[soundId].player.play();
                        }
                    }
                    colBackground: Colors.colLayer2
                    colBackgroundHover: playerPlaying ? Colors.colSecondaryContainerHover : Colors.colPrimaryContainerHover
                }

                // Master pause button (only for master)
                RippleButtonWithIcon {
                    visible: isMaster
                    materialIcon: AmbientSoundsService.masterPaused ? "play_arrow" : "pause"
                    onClicked: AmbientSoundsService.toggleMasterPause()
                    colBackground: Colors.colLayer2
                    colBackgroundHover: Colors.colLayer1Hover
                }

                // Close button (only for active sounds)
                RippleButtonWithIcon {
                    visible: !isMaster && isActive
                    materialIcon: "close"
                    horizontalPadding: 8
                    onClicked: AmbientSoundsService.stopSound(soundId)
                    colBackground: Colors.colLayer2
                    colBackgroundHover: Colors.colErrorContainer
                }
            }
        }
    }

    StyledListView {
        id: listView
        anchors.fill: parent
        spacing: Padding.normal
        clip: true
        header: ColumnLayout {
            width: listView.width
            spacing: Padding.normal

            // Master controls
            SoundItemContainer {
                soundId: ""
                soundVolume: AmbientSoundsService.masterVolume
                playerPlaying: false
                effectivePlaying: !AmbientSoundsService.masterPaused
                soundInfo: null
                isMaster: true
                isActive: true
            }

            Separator {
                visible: AmbientSoundsService.activeSoundsList.length > 0
            }

            // Active sounds
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Padding.normal
                visible: AmbientSoundsService.activeSoundsList.length > 0

                StyledText {
                    text: `Active Sounds (${AmbientSoundsService.activeSoundsList.length})`
                    font.pixelSize: Fonts.sizes.normal
                    color: Colors.colOnLayer1
                }

                Repeater {
                    id: activeRepeater
                    model: AmbientSoundsService.activeSoundsList

                    SoundItemContainer {
                        soundId: modelData.id
                        soundVolume: modelData.volume
                        playerPlaying: modelData.isPlaying
                        effectivePlaying: modelData.isPlaying && !AmbientSoundsService.masterPaused
                        soundInfo: AmbientSoundsService.availableSounds.find(s => s.id === soundId)
                        isMaster: false
                        isActive: true
                    }
                }
            }

            Separator {
                visible: AmbientSoundsService.availableSounds.length > 0
            }

            // Available sounds grid
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Padding.normal

                StyledText {
                    text: `Available (${AmbientSoundsService.availableSounds.length})`
                    font.pixelSize: Fonts.sizes.normal
                    font.weight: Font.Medium
                    color: Colors.colOnLayer1
                    visible: AmbientSoundsService.availableSounds.length > 0
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: gridColumns
                    columnSpacing: Padding.normal
                    rowSpacing: Padding.normal
                    visible: AmbientSoundsService.availableSounds.length > 0

                    Repeater {
                        model: AmbientSoundsService.availableSounds

                        Rectangle {
                            id: iconContainer
                            Layout.fillWidth: true
                            Layout.preferredHeight: 64
                            color: Colors.colLayer2
                            radius: Rounding.normal
                            visible: !AmbientSoundsService.isPlaying(modelData.id)

                            property bool hovered: false

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.hovered = true
                                onExited: parent.hovered = false
                                onClicked: AmbientSoundsService.playSound(modelData.id)
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Padding.normal
                                spacing: Padding.normal

                                Rectangle {
                                    Layout.preferredWidth: iconContainer.height * 0.65
                                    Layout.preferredHeight: iconContainer.height * 0.65
                                    radius: Rounding.normal
                                    color: iconContainer.hovered ? Colors.m3.m3primaryContainer : Colors.colLayer3

                                    MaterialSymbol {
                                        text: modelData.icon
                                        font.pixelSize: 20
                                        color: iconContainer.hovered ? Colors.m3.m3onPrimaryContainer : Colors.colOnLayer3
                                        fill: 1
                                        anchors.centerIn: parent
                                    }

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }
                                    }
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    font.pixelSize: Fonts.sizes.normal
                                    color: Colors.colOnLayer2
                                    elide: Text.ElideRight
                                }

                                MaterialSymbol {
                                    text: "add_circle"
                                    font.pixelSize: 20
                                    color: iconContainer.hovered ? Colors.colPrimary : Colors.colOnLayer2
                                    opacity: iconContainer.hovered ? 1 : 0.5
                                    fill: iconContainer.hovered ? 1 : 0

                                    Behavior on opacity {
                                        Anim {}
                                    }
                                }
                            }

                            Behavior on color {
                                CAnim {}
                            }
                        }
                    }
                }
            }
        }

        PagePlaceholder {
            shown: AmbientSoundsService.availableSounds.length === 0
            icon: "library_music"
            title: "No audio files found"
        }
    }
}
