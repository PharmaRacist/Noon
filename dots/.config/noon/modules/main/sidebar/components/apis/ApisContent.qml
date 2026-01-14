import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtWebView
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services
import qs.modules.main.sidebar.components.apis.medicalDictionary
import qs.modules.main.sidebar.components.apis.translator

Item {
    id: root
    onFocusChanged: swipeView.currentItem.forceActiveFocus()
    signal expandRequested
    property var tabButtonList: [...(Mem.options.policies.ai ? [
                {
                    "icon": "neurology",
                    "name": qsTr(" AI ")
                }
            ] : []), ...(Mem.options.policies.medicalDictionary ? [
                {
                    "icon": "rib_cage",
                    "name": qsTr("Medical")
                }
            ] : []), ...(Mem.options.policies.translator ? [
                {
                    "icon": "translate",
                    "name": qsTr("Dicts")
                }
            ] : []),]
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

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        // Tab strip
        Toolbar {
            visible: tabBar.tabButtonList.length > 1
            Layout.alignment: Qt.AlignHCenter
            ToolbarTabBar {
                id: tabBar
                Layout.alignment: Qt.AlignHCenter
                tabButtonList: root.tabButtonList
                currentIndex: swipeView.currentIndex
                onCurrentIndexChanged: Mem.states.sidebar.apis.selectedTab = currentIndex
            }
        }

        // Content pages
        SwipeView {
            id: swipeView

            Layout.topMargin: Padding.large
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            currentIndex: Mem.states.sidebar.apis.selectedTab
            onCurrentIndexChanged: Mem.states.sidebar.apis.selectedTab = currentIndex
            clip: true
            layer.enabled: true
            contentChildren: [...(Mem.options.policies.ai ? [aiChat.createObject()] : []), ...(Mem.options.policies.medicalDictionary ? [medical.createObject()] : []), ...(Mem.options.policies.translator ? [translator.createObject()] : [])]

            layer.effect: OpacityMask {

                maskSource: Rectangle {
                    width: swipeView.width
                    height: swipeView.height
                    radius: Rounding.small
                }
            }
        }

        Component {
            id: aiChat

            AiChat {
                onExpandRequested: root.expandRequested()
            }
        }
        Component {
            id: translator

            Translator {}
        }

        Component {
            id: medical

            MedicalDictionary {}
        }
    }
}
