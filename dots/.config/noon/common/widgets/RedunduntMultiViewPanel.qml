import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import qs.common
import qs.common.widgets
import qs.services

StyledRect {
    id: root
    color: "transparent"
    radius: Rounding.small
    signal expandRequested

    property int selectedTabIndex: -1
    property bool lazy: true

    required property var tabButtonList
    required property string path

    ColumnLayout {
        anchors.fill: parent
        spacing: Padding.normal

        Toolbar {
            Layout.alignment: Qt.AlignHCenter
            ToolbarTabBar {
                id: tabBar
                Layout.alignment: Qt.AlignHCenter
                tabButtonList: root.tabButtonList
                currentIndex: root.selectedTabIndex
                onCurrentIndexChanged: root.selectedTabIndex = currentIndex
            }
        }

        SwipeView {
            id: swipeView

            Layout.topMargin: Padding.large
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Padding.normal
            currentIndex: root.selectedTabIndex
            onCurrentIndexChanged: root.selectedTabIndex = currentIndex
            clip: true
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: swipeView?.width
                    height: swipeView?.height
                    radius: Rounding.verylarge
                }
            }
            Repeater {
                model: tabButtonList.map(item => item.component)
                Loader {
                    required property var modelData
                    required property int index
                    active: root.lazy && root.selectedTabIndex === index
                    source: root.path + modelData + ".qml"
                    asynchronous: true
                }
            }
            Keys.onPressed: event => {
                if (event.modifiers === Qt.ControlModifier) {
                    switch (event.key) {
                    case Qt.Key_PageDown:
                        Mem.states.sidebar.apis.selectedTab = Math.min(Mem.states.sidebar.apis.selectedTab + 1, root.tabButtonList.length - 1);
                        event.accepted = true;
                        break;
                    case Qt.Key_PageUp:
                        Mem.states.sidebar.apis.selectedTab = Math.max(Mem.states.sidebar.apis.selectedTab - 1, 0);
                        event.accepted = true;
                        break;
                    case Qt.Key_Tab:
                        Mem.states.sidebar.apis.selectedTab = (Mem.states.sidebar.apis.selectedTab + 1) % root.tabButtonList.length;
                        event.accepted = true;
                        break;
                    case Qt.Key_Backtab:
                        Mem.states.sidebar.apis.selectedTab = (Mem.states.sidebar.apis.selectedTab - 1 + root.tabButtonList.length) % root.tabButtonList.length;
                        event.accepted = true;
                        break;
                    case Qt.Key_O:
                        root.expandRequested();
                        event.accepted = true;
                        break;
                    }
                }
            }
        }
    }
}
