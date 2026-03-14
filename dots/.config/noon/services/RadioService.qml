pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import QtMultimedia

Singleton {
    id: root

    // Properties
    property var currentStation
    readonly property string baseUrl: "https://de1.api.radio-browser.info/json"
    property bool isPlaying: false
    property var searchResults: []
    property bool isLoading: false
    property string errorMessage: ""

    // Signals
    signal stationChanged
    signal searchCompleted
    signal playbackStarted
    signal playbackStopped
    signal error(string message)

    // MediaPlayer for radio playback
    MediaPlayer {
        id: radioPlayer
        audioOutput: AudioOutput {
            id: audioOutput
            volume: 1.0
        }

        onPlaybackStateChanged: {
            if (playbackState === MediaPlayer.PlayingState) {
                root.isPlaying = true;
                root.playbackStarted();
            } else if (playbackState === MediaPlayer.StoppedState) {
                root.isPlaying = false;
                root.playbackStopped();
            }
        }

        onErrorOccurred: function (error, errorString) {
            root.errorMessage = "Playback error: " + errorString;
            root.error(root.errorMessage);
            console.error("MediaPlayer error:", errorString);
        }
    }

    // Search stations by name
    function searchByName(query) {
        isLoading = true;
        errorMessage = "";

        const url = `${baseUrl}/stations/byname/${encodeURIComponent(query)}`;

        const xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                isLoading = false;

                if (xhr.status === 200) {
                    try {
                        searchResults = JSON.parse(xhr.responseText);
                        console.log(`Found ${searchResults.length} stations`);
                        searchCompleted();
                    } catch (e) {
                        errorMessage = "Failed to parse response: " + e;
                        error(errorMessage);
                    }
                } else {
                    errorMessage = `HTTP Error: ${xhr.status}`;
                    error(errorMessage);
                }
            }
        };

        xhr.send();
    }

    // Search stations by country
    function searchByCountry(country) {
        isLoading = true;
        errorMessage = "";

        const url = `${baseUrl}/stations/bycountry/${encodeURIComponent(country)}`;

        const xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                isLoading = false;

                if (xhr.status === 200) {
                    try {
                        searchResults = JSON.parse(xhr.responseText);
                        console.log(`Found ${searchResults.length} stations in ${country}`);
                        searchCompleted();
                    } catch (e) {
                        errorMessage = "Failed to parse response: " + e;
                        error(errorMessage);
                    }
                } else {
                    errorMessage = `HTTP Error: ${xhr.status}`;
                    error(errorMessage);
                }
            }
        };

        xhr.send();
    }

    // Search stations by tag
    function searchByTag(tag) {
        isLoading = true;
        errorMessage = "";

        const url = `${baseUrl}/stations/bytag/${encodeURIComponent(tag)}`;

        const xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                isLoading = false;

                if (xhr.status === 200) {
                    try {
                        searchResults = JSON.parse(xhr.responseText);
                        console.log(`Found ${searchResults.length} stations with tag ${tag}`);
                        searchCompleted();
                    } catch (e) {
                        errorMessage = "Failed to parse response: " + e;
                        error(errorMessage);
                    }
                } else {
                    errorMessage = `HTTP Error: ${xhr.status}`;
                    error(errorMessage);
                }
            }
        };

        xhr.send();
    }

    // Advanced search with multiple parameters
    function advancedSearch(params) {
        isLoading = true;
        errorMessage = "";

        const url = `${baseUrl}/stations/search`;

        const xhr = new XMLHttpRequest();
        xhr.open("POST", url, true);
        xhr.setRequestHeader("Content-Type", "application/json");

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                isLoading = false;

                if (xhr.status === 200) {
                    try {
                        searchResults = JSON.parse(xhr.responseText);
                        console.log(`Found ${searchResults.length} stations`);
                        searchCompleted();
                    } catch (e) {
                        errorMessage = "Failed to parse response: " + e;
                        error(errorMessage);
                    }
                } else {
                    errorMessage = `HTTP Error: ${xhr.status}`;
                    error(errorMessage);
                }
            }
        };

        xhr.send(JSON.stringify(params));
    }

    // Play a station
    function playStation(station) {
        // Stop current playback if any
        stop();

        currentStation = station;

        // Click endpoint to register listening
        clickStation(station.stationuuid);

        // Start playback using MediaPlayer
        radioPlayer.source = station.url_resolved;
        radioPlayer.play();

        stationChanged();

        console.log(`Now playing: ${station.name}`);
        console.log(`Stream URL: ${station.url_resolved}`);
    }

    // Play station by index from search results
    function playStationByIndex(index) {
        if (index >= 0 && index < searchResults.length) {
            playStation(searchResults[index]);
        } else {
            errorMessage = "Invalid station index";
            error(errorMessage);
        }
    }

    // Stop playback
    function stop() {
        radioPlayer.stop();
        console.log("Playback stopped");
    }

    // Pause playback
    function pause() {
        radioPlayer.pause();
        console.log("Playback paused");
    }

    // Resume playback
    function resume() {
        if (radioPlayer.playbackState === MediaPlayer.PausedState) {
            radioPlayer.play();
            console.log("Playback resumed");
        }
    }

    // Toggle play/pause
    function togglePlayback() {
        if (isPlaying) {
            pause();
        } else if (currentStation) {
            resume();
        }
    }

    // Set volume (0.0 to 1.0)
    function setVolume(volume) {
        audioOutput.volume = Math.max(0, Math.min(1, volume));
    }

    // Get current volume
    function getVolume() {
        return audioOutput.volume;
    }

    // Mute/unmute
    function toggleMute() {
        audioOutput.muted = !audioOutput.muted;
    }

    // Register a click/listen for statistics
    function clickStation(stationUuid) {
        const url = `${baseUrl}/url/${stationUuid}`;

        const xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        xhr.send();
    }

    // Get station info by UUID
    function getStationByUuid(uuid) {
        const url = `${baseUrl}/stations/byuuid/${uuid}`;

        const xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    const stations = JSON.parse(xhr.responseText);
                    if (stations.length > 0) {
                        playStation(stations[0]);
                    }
                } catch (e) {
                    errorMessage = "Failed to get station: " + e;
                    error(errorMessage);
                }
            }
        };

        xhr.send();
    }

    // Helper function to get Quran stations
    function searchQuranStations() {
        advancedSearch({
            name: "قرآن",
            limit: 100,
            order: "votes",
            reverse: true
        });
    }

    // Helper function to get Egyptian Quran radio
    function searchEgyptianQuranRadio() {
        advancedSearch({
            name: "القرآن الكريم",
            country: "Egypt",
            limit: 50
        });
    }

    // Get current playback info
    function getCurrentStationInfo() {
        if (currentStation) {
            return {
                name: currentStation.name,
                country: currentStation.country,
                language: currentStation.language,
                tags: currentStation.tags,
                bitrate: currentStation.bitrate,
                codec: currentStation.codec,
                homepage: currentStation.homepage,
                isPlaying: isPlaying,
                volume: audioOutput.volume,
                isMuted: audioOutput.muted
            };
        }
        return null;
    }
}
