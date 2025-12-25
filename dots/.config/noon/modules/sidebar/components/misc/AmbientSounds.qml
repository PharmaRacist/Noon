import "./ambientSounds"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Item {
    id: root

    property int gridColumns: 1

    PagePlaceholder {
        z: -1
        shown: AmbientSoundsService.activeSoundsList.length === 0
        icon: "relax"
        title: "There is no Active Sounds"
        description: "swipe below to show avilable sounds"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Padding.huge

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
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: Padding.normal
            visible: AmbientSoundsService.activeSoundsList.length > 0

            Repeater {
                id: activeRepeater

                model: AmbientSoundsService.activeSoundsList

                SoundItemContainer {
                    soundId: modelData.id
                    soundVolume: modelData.volume
                    playerPlaying: modelData.isPlaying
                    effectivePlaying: modelData.isPlaying && !AmbientSoundsService.masterPaused
                    soundInfo: AmbientSoundsService.availableSounds.find((s) => {
                        return s.id === soundId;
                    })
                    isMaster: false
                    isActive: true
                }

            }

        }

        Spacer {
        }

    }

    BottomDialog {
        enableStagedReveal: true
        bottomAreaReveal: true
        hoverHeight: 200
        collapsedHeight: 400
        expandedHeight: parent.height * 0.75

        contentItem: AvilableSoundsList {
        }

    }

}
