import "."
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    property bool expanded: false
    property var tabButtonList: [
        {
            "icon": "music_note",
            "name": qsTr("Playing")
        },
        {
            "icon": "playlist_add",
            "name": qsTr("Tracks")
        }
    ]
    spacing: Appearance.padding.huge
    CurrentTrackView {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

    TracksTab {
        visible: root.expanded
        Layout.maximumWidth: 325
        Layout.margins: Appearance.padding.small
        Layout.fillHeight: true
        Layout.fillWidth: true
    }
}
