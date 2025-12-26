import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

 StyledRect {
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
        radius: Rounding.verylarge
        clip: true
        z: 0

        RowLayout {
            anchors.fill: parent

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
            component ControlButton:RippleButtonWithIcon {
                    implicitSize:32
                    Layout.preferredWidth:implicitSize
                    colBackground: Colors.colLayer3
                    buttonRadius:Rounding.full
                    colBackgroundHover: playerPlaying ? Colors.colSecondaryContainerHover : Colors.colPrimaryContainerHover
                }

            component Controls:StyledRect {
                implicitWidth: row.implicitWidth + Padding.normal 
                implicitHeight:row.implicitHeight + Padding.normal 
                color:Colors.colLayer2
                radius:Rounding.full

                RowLayout {
                    id:row
                    anchors.centerIn:parent
                    spacing:Padding.small
                    ControlButton {
                        visible: !isMaster
                        materialIcon: playerPlaying ? "pause" : "play_arrow"
                        releaseAction:()=> {
                            if (playerPlaying) {
                                AmbientSoundsService.activeSounds[soundId].player.pause();
                            } else {
                                AmbientSoundsService.activeSounds[soundId].player.play();
                            }
                        }

                    }

                ControlButton {
                    visible: isMaster
                    materialIcon: AmbientSoundsService.masterPaused ? "play_arrow" : "pause"
                    releaseAction:()=> AmbientSoundsService.toggleMasterPause()
                }

                ControlButton {
                    visible: !isMaster && isActive
                    materialIcon: "close"
                    releaseAction:()=> AmbientSoundsService.stopSound(soundId)
                }

                }
            }
            // Controls column
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: Padding.normal
                spacing: Padding.huge

                StyledSlider {
                    id: slider
                    Layout.fillWidth: true
                    from: 0
                    to: 1
                    value: soundVolume
                    highlightColor: Colors.colPrimary
                    trackColor: Colors.colPrimaryContainer
                    handleColor: Colors.colOnPrimaryContainer

                    onMoved: 
                        if (isMaster) {
                            AmbientSoundsService.masterVolume = value;
                        } else {
                            AmbientSoundsService.setSoundVolume(soundId, value);
                        
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
                Controls {

                }
            }
        }
    }
