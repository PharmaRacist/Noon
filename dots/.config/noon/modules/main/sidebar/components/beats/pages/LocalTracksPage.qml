import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.common.functions
import qs.services
import "../local"
import "../"

StyledRect {
    id: root

    property bool expanded

    ScriptModel {
        id: filteredModel
        values: {
            const query = controls.inputArea.text;
            const searchBy = text => {
                if (query === "")
                    return true;
                else if (text)
                    return (text).toLowerCase().includes(query);
            };
            return BeatsService.tracksList.filter(entry => searchBy(entry.fileName) || searchBy(entry?.title) || searchBy(entry.artist));
        }
    }

    StyledRectangularShadow {
        target: controls
    }

    LocalControls {
        id: controls
    }

    radius: Rounding.verylarge
    color: colors.colLayer1
    colors: BeatsService.colors

    StyledGridView {
        id: grid
        clip: true
        anchors.fill: parent
        anchors.margins: Padding.large
        reuseItems: false
        model: filteredModel
        property int columns: root.expanded ? 4 : 2
        cellWidth: width / columns
        cellHeight: cellWidth

        delegate: TrackItem {
            implicitSize: grid.cellWidth - Padding.large
            title: modelData?.title ?? ""
            artist: modelData?.artist ?? ""
            coverArt: modelData?.cover_art ?? ""
            eventArea.onClicked: event => {
                if (event.button === Qt.LeftButton) {
                    BeatsService.playTrack(modelData.playlist_index);
                } else if (event.button === Qt.RightButton) {
                    menu.popup();
                }
            }
            // REWORK
            TrackContextMenu {
                id: menu
                trackPath: modelData.filePath
                trackName: modelData.title
            }
        }
    }
    MouseArea {
        id: dismissArea
        z: controls.z - 1
        preventStealing: true
        hoverEnabled: true
        enabled: controls._expanded
        anchors.fill: parent
        onClicked: controls.mode = ""
    }
}
