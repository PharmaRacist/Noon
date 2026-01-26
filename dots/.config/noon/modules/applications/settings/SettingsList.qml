import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.store
import qs.common
import qs.common.functions
import qs.common.utils
import qs.common.widgets

Item {
    id: root
    property string currentPath: GlobalStates.applications.editor.currentPath

    anchors {
        fill: parent
        margins: Padding.normal
    }

    StyledListView {
        id: listView
        anchors.fill: parent
        radius: Rounding.verylarge
        clip: true
        model: SettingsData.tweaks
        delegate: StyledDelegateItem {
            expanded: Mem.states.applications.settings.sidebar_expanded
            required property var modelData
            property var index
            shape: MaterialShape.Shape.Cookie4Sided
            title: modelData.section
            subtext: modelData.shell || ""
            materialIcon: modelData.icon || ""
            releaseAction: () => {
                Mem.states.applications.settings.cat = modelData.section;
            }
        }
    }
}
