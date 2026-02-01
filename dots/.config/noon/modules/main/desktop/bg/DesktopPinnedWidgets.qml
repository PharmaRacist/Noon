import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.common
import qs.common.widgets
import qs.modules.main.bar.components
import qs.services
import qs.store

StyledRect {
    id: root
    color: "transparent"

    readonly property string widgetsPath: "./../../sidebar/components/widgets/widgets/"
    readonly property var mem: Mem.states.sidebar.widgets
    readonly property var desktop: mem.desktop
    readonly property var widgetObjects: desktop.map(widgetId => {
        const widgetData = WidgetsData.db.find(item => item.id === widgetId);
        return {
            id: widgetId,
            component: widgetData?.component || "",
            expanded: mem.expanded.find(item => item === widgetId),
            pilled: mem.pilled.find(item => item === widgetId)
        };
    })

    anchors {
        top: parent.top
        right: parent.right
        bottom: parent.bottom
    }
    implicitWidth: 450
    z: 9999

    RowLayout {
        anchors.fill: parent
        anchors.margins: Padding.massive
        Spacer {}

        Flow {
            Layout.preferredWidth: 375
            Layout.fillHeight: true
            layoutDirection: Flow.TopToBottom
            spacing: Padding.huge

            Repeater {
                model: widgetObjects
                delegate: Loader {
                    required property var modelData
                    asynchronous: true
                    source: root.widgetsPath + modelData.component + ".qml"
                    width: modelData.expanded ? parent.width : 180
                    onLoaded: if (item) {
                        if ("expanded" in item) {
                            item.expanded = Qt.binding(() => modelData.expanded);
                        }
                        if ("pill" in item) {
                            item.pill = Qt.binding(() => modelData.pilled);
                        }
                    }
                }
            }
        }
    }
}
