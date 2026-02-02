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
    signal expandRequested

    readonly property var tabButtonList: [
        {
            "icon": "neurology",
            "enabled": Mem.options.policies.ai > 0,
            "name": " AI ",
            "component": "AiChat"
        },
        {
            "icon": "rib_cage",
            "enabled": Mem.options.policies.medicalDictionary > 0,
            "name": "Medical",
            "component": "medicalDictionary/MedicalDictionary"
        },
        {
            "icon": "translate",
            "enabled": Mem.options.policies.translator > 0,
            "name": "Dicts",
            "component": "translator/Translator"
        }
    ]

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
                tabButtonList: root.tabButtonList.filter(item => item.enabled)
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
            Repeater {
                model: root.tabButtonList.filter(item => item.enabled).map(item => item.component)
                delegate: Loader {
                    required property var modelData
                    asynchronous: true
                    source: modelData + ".qml"
                }
            }
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: swipeView.width
                    height: swipeView.height
                    radius: Rounding.small
                }
            }
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
