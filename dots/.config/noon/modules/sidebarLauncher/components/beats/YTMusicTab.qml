import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Item {
    id: ytMusicTab

    property string searchQuery: ""
    property var searchResults: []
    property bool searchLoading: false
    property int maxResults: 25 // Configurable max results to show
    property bool hasMoreResults: false
    property string lastSearchQuery: ""

    signal playTrack(string query)
    signal downloadTrack(string query)
    signal playVideo(string query)

    // FileView to monitor search results JSON file
    FileView {
        id: searchResultsFileView
        path: Qt.resolvedUrl("file:///tmp/ytmusic_search_results.json")
        watchChanges: true

        onFileChanged: {
            this.reload();
            loadSearchResultsTimer.start();
        }

        onLoadedChanged: {
            if (loaded) {
                loadSearchResultsTimer.start();
            }
        }

        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                console.log("[YTMusic] Results file not found yet, waiting...");
            } else {
                ytMusicTab.searchLoading = false;
            }
        }
    }

    Timer {
        id: loadSearchResultsTimer
        interval: 200 // Small delay to ensure file is fully written
        running: false
        onTriggered: {
            parseJsonResults(searchResultsFileView.text());
        }
    }

    function executeYtDlpSearch(query) {
        var searchQuery = `ytsearch${maxResults}:'${query}'`;
        var outputFile = "/tmp/ytmusic_search_results.json";
        const command = `yt-dlp --no-playlist --flat-playlist --dump-json --ignore-config --write-thumbnail --skip-download ${searchQuery} > ${outputFile}`;
        Noon.exec(command);
    }

    function parseJsonResults(jsonText) {
        try {
            if (!jsonText || jsonText.trim() === "") {
                console.log("[YTMusic] Results file is empty, waiting for data...");
                return;
            }

            var results = [];
            var lines = jsonText.trim().split('\n');

            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                if (line) {
                    try {
                        var jsonObj = JSON.parse(line);
                        results.push({
                            title: jsonObj.title || "Unknown Title",
                            artist: jsonObj.uploader || jsonObj.channel || "Unknown Artist",
                            duration: jsonObj.duration_string || formatDuration(jsonObj.duration) || "0:00",
                            url: jsonObj.webpage_url || jsonObj.url || "",
                            id: jsonObj.id || "",
                            thumbnail: jsonObj.thumbnail || jsonObj.thumbnails?.[0]?.url || "",
                            description: jsonObj.description || "",
                            view_count: jsonObj.view_count || 0,
                            query: jsonObj.webpage_url || ytMusicTab.lastSearchQuery
                        });
                    } catch (parseError) {}
                }
            }

            if (results.length > 0) {
                ytMusicTab.searchResults = results;
                ytMusicTab.hasMoreResults = results.length >= ytMusicTab.maxResults;
                ytMusicTab.searchLoading = false;

                // console.log("[YTMusic] Loaded", results.length, "search results from JSON");
            } else {
                console.log("[YTMusic] No valid results found in JSON file");
            }
        } catch (e) {
            // console.error("[YTMusic] Error parsing JSON results:", e);
            ytMusicTab.searchLoading = false;
            // Could fall back to simulation here if needed
        }
    }

    function formatDuration(seconds) {
        if (!seconds || seconds <= 0)
            return "0:00";
        var mins = Math.floor(seconds / 60);
        var secs = seconds % 60;
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    // Timer to check for results file periodically
    Timer {
        id: searchResultsTimer
        interval: 2000
        repeat: true
        property int maxRetries: 15  // Stop after 30 seconds (15 * 2s)
        property int currentRetries: 0

        onTriggered: {
            currentRetries++;
            loadSearchResults();

            // Stop after max retries to avoid infinite polling
            if (currentRetries >= maxRetries) {
                console.log("Search timeout - no results file found");
                stop();
                currentRetries = 0;
                ytMusicTab.searchLoading = false;
            }
        }

        function restart() {
            currentRetries = 0;
            start();
        }
    }

    function searchYouTubeMusic(query) {
        if (!query.trim())
            return;

        ytMusicTab.searchLoading = true;
        ytMusicTab.searchResults = [];
        ytMusicTab.lastSearchQuery = query.trim();
        ytMusicTab.hasMoreResults = false;

        // Try to execute yt-dlp search
        executeYtDlpSearch(ytMusicTab.lastSearchQuery);
    }

    function clearSearch() {
        searchField.text = "";
        searchField.focus = true;
        searchResults = [];
        hasMoreResults = false;
        maxResults = 50; // Reset to default
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Content area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Search Results ListView
            StyledListView {
                id: ytSearchListView
                anchors.fill: parent
                spacing: 6
                clip: true
                visible: ytMusicTab.searchResults.length > 0 && !ytMusicTab.searchLoading
                model: ytMusicTab.searchResults.length

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: ytSearchListView.width
                        height: ytSearchListView.height
                        radius: Rounding.normal
                    }
                }

                delegate: Rectangle {
                    id: ytDelegate
                    width: ytSearchListView.width
                    height: 65
                    radius: Rounding.normal
                    color: ytMouseArea.containsMouse ? TrackColorsService.colors.colSecondaryContainerHover : ytMouseArea.pressed ? TrackColorsService.colors.colSecondaryContainerActive : TrackColorsService.colors.colLayer1

                    property var resultData: ytMusicTab.searchResults[model.index] || {}

                    Behavior on color {
                        CAnim {}
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 12

                        // Thumbnail area
                        Rectangle {
                            id: thumbnailContainer
                            Layout.leftMargin: 10
                            implicitWidth: 40
                            implicitHeight: 40
                            radius: 99
                            color: TrackColorsService.colors.colLayer3
                            Layout.alignment: Qt.AlignVCenter
                            clip: true

                            // Thumbnail image
                            Image {
                                id: thumbnailImage
                                anchors.fill: parent
                                source: resultData.thumbnail || ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                                visible: status === Image.Ready

                                // Rounded corners effect
                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    maskSource: Rectangle {
                                        width: thumbnailImage.width
                                        height: thumbnailImage.height
                                        radius: 99
                                    }
                                }
                            }

                            // Fallback icon when no thumbnail
                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: "music_note"
                                font.pixelSize: 24
                                color: TrackColorsService.colors.colOnLayer1
                                opacity: 0.6
                                visible: !thumbnailImage.visible
                            }
                        }

                        // Text content
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            StyledText {
                                Layout.fillWidth: true
                                font.pixelSize: Fonts.sizes.small
                                color: TrackColorsService.colors.colOnLayer1
                                opacity: 0.9
                                text: resultData.title || "Unknown Title"
                                elide: Text.ElideRight
                                maximumLineCount: 2
                                wrapMode: Text.WordWrap
                            }

                            StyledText {
                                Layout.fillWidth: true
                                font.pixelSize: Fonts.sizes.verysmall
                                opacity: 0.6
                                color: TrackColorsService.colors.colSubtext
                                text: resultData.artist || "Unknown Artist"
                                elide: Text.ElideRight
                            }
                        }

                        // Action buttons
                        RowLayout {
                            spacing: 3
                            Layout.rightMargin: 16
                            RippleButton {
                                implicitWidth: 26
                                implicitHeight: 26
                                buttonRadius: 18
                                onClicked: ytMusicTab.playTrack(resultData.url || resultData.query || "")

                                contentItem: MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: "play_arrow"
                                    fill: 1
                                    font.pixelSize: 20
                                    color: TrackColorsService.colors.colPrimary
                                }
                            }

                            RippleButton {
                                implicitWidth: 26
                                implicitHeight: 26
                                buttonRadius: 18
                                onClicked: ytMusicTab.playVideo(resultData.query)

                                contentItem: MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: "cast_connected"
                                    fill: 1
                                    font.pixelSize: 20
                                    color: TrackColorsService.colors.colPrimary
                                }
                            }

                            RippleButton {
                                implicitWidth: 26
                                implicitHeight: 26
                                buttonRadius: 18
                                onClicked: ytMusicTab.downloadTrack(resultData.url || resultData.query || "")

                                contentItem: MaterialSymbol {
                                    anchors.centerIn: parent
                                    fill: 1
                                    text: "download"
                                    font.pixelSize: 20
                                    color: TrackColorsService.colors.colPrimary
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: ytMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.NoButton
                    }
                }
            }
            StyledBusyIndicator {}

            // Empty state
            Item {
                anchors.fill: parent
                visible: ytMusicTab.searchResults.length === 0 && !ytMusicTab.searchLoading

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 16

                    MaterialSymbol {
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: 64
                        color: TrackColorsService.colors.colSubtext
                        text: "search"
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: Fonts.sizes.large
                        color: TrackColorsService.colors.colSubtext
                        text: qsTr("Search YouTube")
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: Fonts.sizes.normal
                        color: TrackColorsService.colors.colOnLayer1
                        text: qsTr("Enter a song, artist, or album name to search")
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}
