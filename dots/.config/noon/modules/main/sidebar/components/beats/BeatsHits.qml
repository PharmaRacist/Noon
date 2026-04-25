import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

StyledRect {
    id: root
    color: Colors.colLayer1
    radius: Rounding.verylarge
    property bool expanded
    property bool isSearching: false
    onIsSearchingChanged: controls.inputArea.forceActiveFocus()

    function loadMore(i) {
        if (BeatsHitsService.isBusy)
            return;
        if (isSearching) {
            BeatsHitsService.searchMore(controls.inputArea.text);
        } else {
            BeatsHitsService.request(i);
        }
    }
    StyledRectangularShadow {
        target: controls
    }
    HitsControls {
        id: controls
    }
    ScrollEdgeFade {
        target: grid
    }
    StyledGridView {
        id: grid
        z: 1
        anchors.margins: Padding.huge
        anchors.fill: parent
        readonly property int columns: root.expanded ? 4 : 2
        cellWidth: width / columns
        cellHeight: cellWidth
        reuseItems: false
        model: ScriptModel {
            values: {
                if (root.isSearching)
                    return BeatsHitsService.searchResults;
                else if (Mem.states.services.beats.shuffleHits)
                    return BeatsHitsService.hits.sort(() => Math.random() - 0.5);
                else
                    return BeatsHitsService.hits;
            }
        }
        delegate: Hit {
            implicitSize: grid.cellWidth - Padding.large
        }
        onContentYChanged: {
            if (contentHeight > 0 && contentY + height >= contentHeight - height * 0.25)
                root.loadMore();
        }
    }
    MaterialLoadingIndicator {
        z: 2
        visible: loading
        loading: BeatsHitsService.isBusy
        anchors.top: parent.top
        anchors.topMargin: Padding.massive
        anchors.horizontalCenter: parent.horizontalCenter
        implicitSize: 54
    }
}
