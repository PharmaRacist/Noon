import "./ambientSounds"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

Item {
    id: root
    
    property int gridColumns: 1
    
    PagePlaceholder {
        z: -1
        shown: AmbientSoundsService.activeSounds.length === 0
        icon: "relax"
        title: "There is no Active Sounds"
        description: "swipe below to show available sounds"
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
            visible: AmbientSoundsService.activeSounds.length > 0
        }
        
        // Active sounds
        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: Padding.normal
            visible: AmbientSoundsService.activeSounds.length > 0
            
            Repeater {
                id: activeRepeater
                model: AmbientSoundsService.activeSounds
                
                SoundItemContainer {
                    required property var modelData
                    required property int index
                    
                    property var _soundInfo: AmbientSoundsService.availableSounds.find((s) => s.id === modelData.id)
                    
                    soundId: modelData.id
                    soundVolume: modelData.volume
                    playerPlaying: AmbientSoundsService.activeSounds[index]?.isPlaying ?? false
                    effectivePlaying: (AmbientSoundsService.activeSounds[index]?.isPlaying ?? false) && !AmbientSoundsService.masterPaused
                    soundInfo: _soundInfo ?? null
                    isMaster: false
                    isActive: true
                    visible: _soundInfo !== null && _soundInfo !== undefined
                }
            }
        }
        
        Spacer {}
    }
    
    BottomDialog {
        enableStagedReveal: true
        bottomAreaReveal: true
        hoverHeight: 200
        collapsedHeight: 400
        expandedHeight: parent.height * 0.75
        contentItem: AvilableSoundsList {}
    }
}