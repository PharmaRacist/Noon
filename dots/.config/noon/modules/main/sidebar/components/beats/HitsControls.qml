import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services
import "hits"

StyledRect {
    id: bg
    z: 9999
    clip: true
    property var songData

    property string mode: "options"
    readonly property var dict: {
        "options": optionsComponent,
        "preview": previewComponent
    }
    readonly property Component optionsComponent: HitsOptions {}
    readonly property Component previewComponent: HitsPreview {}

    property bool _expanded: false
    property alias inputArea: bottomRow.inputArea
    anchors.margins: Padding.huge
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter

    radius: Rounding.huge
    color: Colors.m3.m3surfaceContainerHighest

    states: [
        State {
            name: "expanded"
            when: _expanded

            PropertyChanges {
                target: bg
                width: parent?.width - (anchors.margins * 2)
                height: 225
            }
        },
        State {
            name: "collapsed"
            when: !_expanded

            PropertyChanges {
                target: bg
                width: root?.isSearching ? 320 : bottomRow?.contentWidth
                height: 65
            }
        }
    ]

    transitions: Transition {
        Anim {
            properties: "width,height,x,y,opacity"
        }
    }

    StyledLoader {
        active: bg._expanded

        anchors.bottom: bottomRow.top
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left

        anchors.leftMargin: Padding.huge
        anchors.rightMargin: Padding.huge

        sourceComponent: dict[bg.mode]

        onLoaded: {
            if ("songData" in _item)
                _item.songData = Qt.binding(() => bg.songData);
        }
    }
    HitsBottomRow {
        id: bottomRow
    }
}
