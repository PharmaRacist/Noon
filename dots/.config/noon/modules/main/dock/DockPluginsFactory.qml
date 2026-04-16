import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.store
import qs.common
import qs.common.widgets
import "components"

Repeater {
    Layout.fillHeight: true
    Layout.fillWidth: true
    property bool leftMode: false
    visible: model.length > 0
    model: ScriptModel {
        values: Object.values(PluginsManager?.dockPlugins).filter(i => i?.direction === (leftMode ? "left" : "right"))
    }
    delegate: StyledLoader {
        required property var modelData
        active: modelData.enabled
        source: "file://" + modelData.entry
        onLoaded: {
            BarData.layoutProps.forEach(prop => {
                Layout[prop] = Qt.binding(() => _item?.Layout?.[prop]);
            });
        }
    }
}
