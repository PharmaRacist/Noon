import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import qs.modules.common
import qs.modules.common.widgets
import qs.services

StyledRect {
    id: root
    color: "transparent"
    radius: Rounding.small
    clip: true
    property var tabButtonList: [
        {
            "icon": "discover_tune",
            "name": qsTr("Mixer")
        },
        {
            "icon": "relax",
            "name": qsTr("Ambients")
        },
        {
            "icon": "hourglass",
            "name": qsTr("Pomo")
        },
        {
            "icon": "alarm",
            "name": qsTr("Alarms")
        }
        // {
        //     "icon": "energy_savings_leaf",
        //     "name": qsTr("Resources")
        // }
        ,
    ]
    ColumnLayout {
        anchors.fill: parent
        spacing: Padding.normal

        // Tab strip
        Toolbar {
            Layout.alignment: Qt.AlignHCenter
            ToolbarTabBar {
                id: tabBar
                Layout.alignment: Qt.AlignHCenter
                tabButtonList: root.tabButtonList
                currentIndex: Mem.states.sidebar.misc.selectedTabIndex
                onCurrentIndexChanged: Mem.states.sidebar.misc.selectedTabIndex = currentIndex
            }
        }

        SwipeView {
            id: swipeView

            Layout.topMargin: Padding.large
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Padding.normal
            currentIndex: Mem.states.sidebar.misc.selectedTabIndex
            onCurrentIndexChanged: Mem.states.sidebar.misc.selectedTabIndex = currentIndex
            clip: true
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: swipeView?.width
                    height: swipeView?.height
                    radius: Rounding.verylarge
                }
            }

            VolumeMixer {}
            AmbientSounds {}
            PomoWidget {}
            AlarmWidget {}
            // ResourcesWidget {}
            Keys.onPressed: event => {
                if (event.modifiers === Qt.ControlModifier) {
                    if (event.key === Qt.Key_PageDown) {
                        Mem.states.sidebar.misc.selectedTabIndex = Math.min(Mem.states.sidebar.misc.selectedTabIndex + 1, root.tabButtonList.length - 1);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_PageUp) {
                        Mem.states.sidebar.misc.selectedTabIndex = Math.max(Mem.states.sidebar.misc.selectedTabIndex - 1, 0);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Tab) {
                        Mem.states.sidebar.misc.selectedTabIndex = (Mem.states.sidebar.misc.selectedTabIndex + 1) % root.tabButtonList.length;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Backtab) {
                        Mem.states.sidebar.misc.selectedTabIndex = (Mem.states.sidebar.misc.selectedTabIndex - 1 + root.tabButtonList.length) % root.tabButtonList.length;
                        event.accepted = true;
                    }
                }
            }
        }
    }
}
