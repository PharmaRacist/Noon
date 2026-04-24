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
    function loadMore(i) {
        if (!BeatsHitsService.isBusy)
            BeatsHitsService.request(i);
    }
    StyledRect {
        z: 9999
        anchors.margins: Padding.huge
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 100
        height: 45
        radius: Rounding.huge
        color: Colors.colLayer3
        ButtonGroup {
            anchors.fill: parent
            Repeater {
                model: [
                    {
                        icon: "refresh",
                        action: () => {
                            BeatsHitsService.refresh(64);
                        }
                    }
                ]
                delegate: GroupButtonWithIcon {
                    baseSize: 45
                    materialIcon: modelData.icon
                    releaseAction: () => modelData.action()
                }
            }
        }
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
            values: BeatsHitsService.hits
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
