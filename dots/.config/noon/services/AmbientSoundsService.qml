pragma Singleton
import QtQuick
import QtMultimedia
import Quickshell
import Qt.labs.folderlistmodel
import qs.modules.common
import qs.modules.common.widgets

Singleton {
    id: root

    readonly property var iconMap: ({
            "rain": "water_drop",
            "storm": "thunderstorm",
            "waves": "waves",
            "ocean": "waves",
            "fire": "local_fire_department",
            "fireplace": "local_fire_department",
            "wind": "air",
            "birds": "flutter_dash",
            "bird": "flutter_dash",
            "stream": "water",
            "river": "water",
            "water": "water",
            "white": "graphic_eq",
            "pink": "graphic_eq",
            "noise": "graphic_eq",
            "coffee": "local_cafe",
            "cafe": "local_cafe",
            "shop": "local_cafe",
            "train": "train",
            "boat": "sailing",
            "ship": "sailing",
            "night": "nightlight",
            "summer": "wb_sunny",
            "city": "location_city",
            "urban": "location_city"
        })

    property var availableSounds: []
    property var activeSounds: ({})
    property real masterVolume: 1
    property bool muted: false
    property bool masterPaused: false  // Master pause state
    readonly property string audioDir: Directories.sounds + "ambient"

    // UI-friendly active sounds list
    readonly property var activeSoundsList: {
        return Object.keys(activeSounds).map(soundId => ({
                    id: soundId,
                    name: activeSounds[soundId].name,
                    volume: activeSounds[soundId].volume,
                    isPlaying: activeSounds[soundId].player.playbackState === MediaPlayer.PlayingState
                }));
    }

    FolderListModel {
        id: audioFolderModel
        folder: ""
        nameFilters: ["*.mp3", "*.ogg", "*.wav", "*.flac", "*.m4a"]
        showDirs: false
        showFiles: true
        onCountChanged: {
            if (folder !== "") {
                scanAudioFiles();
            }
        }
    }

    Component.onCompleted: {
        Qt.callLater(() => {
            loadState();
            loadAvailableSounds();
        });
    }

    onMasterVolumeChanged: {
        saveState();
        updateAllVolumes();
    }

    onMutedChanged: {
        saveState();
        updateAllVolumes();
    }

    onMasterPausedChanged: {
        saveState();
        updateAllPlayback();
    }

    function saveState() {
        Mem.states.services.ambientSounds.masterVolume = masterVolume;
        Mem.states.services.ambientSounds.muted = muted;
        Mem.states.services.ambientSounds.masterPaused = masterPaused;
        Mem.states.services.ambientSounds.availableSounds = availableSounds;

        const activeSoundsArray = Object.keys(activeSounds).map(soundId => ({
                    id: soundId,
                    volume: activeSounds[soundId].volume,
                    name: activeSounds[soundId].name
                }));

        Mem.states.services.ambientSounds.activeSounds = activeSoundsArray;
    }

    function loadState() {
        try {
            const savedState = Mem.states.services.ambientSounds;

            if (!savedState) {
                return;
            }

            if (savedState.masterVolume !== undefined && savedState.masterVolume !== null) {
                masterVolume = savedState.masterVolume;
            }
            if (savedState.muted !== undefined && savedState.muted !== null) {
                muted = savedState.muted;
            }
            if (savedState.masterPaused !== undefined && savedState.masterPaused !== null) {
                masterPaused = savedState.masterPaused;
            }

            if (savedState.availableSounds && savedState.availableSounds.length > 0) {
                availableSounds = savedState.availableSounds;
            }

            if (savedState.activeSounds && savedState.activeSounds.length > 0) {
                Qt.callLater(() => {
                    for (let i = 0; i < savedState.activeSounds.length; i++) {
                        const soundData = savedState.activeSounds[i];
                        const soundExists = availableSounds.find(s => s.id === soundData.id);
                        if (soundExists) {
                            playSound(soundData.id, soundData.volume);
                        }
                    }
                });
            }
        } catch (e) {
            console.error("AmbientSound: Error loading state:", e);
        }
    }

    function loadAvailableSounds() {
        if (!availableSounds || availableSounds.length === 0) {
            scanDirectory();
        }
    }

    function scanDirectory() {
        audioFolderModel.folder = Qt.resolvedUrl(root.audioDir);
    }

    function scanAudioFiles() {
        const sounds = [];

        for (let i = 0; i < audioFolderModel.count; i++) {
            const fileName = audioFolderModel.get(i, "fileName");
            const fileUrl = audioFolderModel.get(i, "fileUrl");

            const nameWithoutExt = fileName.replace(/\.[^.]+$/, '');
            const displayName = nameWithoutExt.replace(/[_-]/g, ' ').split(' ').map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()).join(' ');
            const lowerName = nameWithoutExt.toLowerCase();
            let icon = "music_note";

            for (const [key, value] of Object.entries(iconMap)) {
                if (lowerName.includes(key)) {
                    icon = value;
                    break;
                }
            }

            sounds.push({
                id: nameWithoutExt.toLowerCase().replace(/[^a-z0-9]/g, '_'),
                name: displayName,
                icon: icon,
                filePath: fileUrl,
                fileName: fileName
            });
        }

        availableSounds = sounds;
        saveState();
    }

    function playSound(soundId, volume = null) {
        if (activeSounds[soundId]) {
            return;
        }

        const sound = availableSounds.find(s => s.id === soundId);
        if (!sound) {
            console.error("AmbientSound: Sound not found:", soundId);
            return;
        }

        const initialVolume = volume !== null ? volume : masterVolume;

        const player = playerComponent.createObject(root);

        if (player) {
            player.source = sound.filePath;
            player.audioOutput.volume = calculateVolume(initialVolume);

            // Respect master pause state
            if (!masterPaused) {
                player.play();
            } else {
                player.pause();
            }

            activeSounds[soundId] = {
                player: player,
                volume: initialVolume,
                name: sound.name
            };
            activeSoundsChanged();

            saveState();
        }
    }

    function stopSound(soundId) {
        if (!activeSounds[soundId]) {
            return;
        }

        const soundData = activeSounds[soundId];
        soundData.player.stop();
        soundData.player.destroy();

        delete activeSounds[soundId];
        activeSoundsChanged();

        saveState();
    }

    function toggleSound(soundId, volume = null) {
        if (activeSounds[soundId]) {
            stopSound(soundId);
        } else {
            playSound(soundId, volume);
        }
    }

    function setSoundVolume(soundId, volume) {
        if (!activeSounds[soundId]) {
            return;
        }

        const clampedVolume = Math.max(0, Math.min(1, volume));
        activeSounds[soundId].volume = clampedVolume;
        activeSounds[soundId].player.audioOutput.volume = calculateVolume(clampedVolume);
        activeSoundsChanged();

        saveState();
    }

    function toggleMasterPause() {
        masterPaused = !masterPaused;
    }

    function toggleAllSounds() {
        const soundIds = Object.keys(activeSounds);

        if (soundIds.length === 0) {
            return;
        }

        if (masterPaused) {
            // Resume all sounds
            soundIds.forEach(soundId => {
                const soundData = activeSounds[soundId];
                if (soundData.player.playbackState !== MediaPlayer.PlayingState) {
                    soundData.player.play();
                }
            });
            masterPaused = false;
        } else {
            // Pause all sounds
            soundIds.forEach(soundId => {
                const soundData = activeSounds[soundId];
                if (soundData.player.playbackState === MediaPlayer.PlayingState) {
                    soundData.player.pause();
                }
            });
            masterPaused = true;
        }
    }

    function stopAll() {
        const soundIds = Object.keys(activeSounds);
        soundIds.forEach(soundId => {
            stopSound(soundId);
        });
        masterPaused = false;
    }

    function setAllVolumes(volume) {
        Object.keys(activeSounds).forEach(soundId => {
            setSoundVolume(soundId, volume);
        });
    }

    function isPlaying(soundId) {
        return !!activeSounds[soundId];
    }

    function getSoundVolume(soundId) {
        return activeSounds[soundId]?.volume ?? masterVolume;
    }

    function toggleMute() {
        muted = !muted;
    }

    function refresh() {
        scanDirectory();
    }

    function calculateVolume(soundVolume) {
        return muted ? 0 : soundVolume * masterVolume;
    }

    function updateAllVolumes() {
        Object.keys(activeSounds).forEach(soundId => {
            const soundData = activeSounds[soundId];
            soundData.player.audioOutput.volume = calculateVolume(soundData.volume);
        });
    }

    function updateAllPlayback() {
        Object.keys(activeSounds).forEach(soundId => {
            const soundData = activeSounds[soundId];
            if (masterPaused) {
                if (soundData.player.playbackState === MediaPlayer.PlayingState) {
                    soundData.player.pause();
                }
            } else {
                if (soundData.player.playbackState !== MediaPlayer.PlayingState) {
                    soundData.player.play();
                }
            }
        });
    }

    Component {
        id: playerComponent
        MediaPlayer {
            loops: MediaPlayer.Infinite
            audioOutput: AudioOutput {
                muted: false
            }
        }
    }
}
