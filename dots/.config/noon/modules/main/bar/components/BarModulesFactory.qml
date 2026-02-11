import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.store

Repeater {
    id: root
    property bool vertical: false
    delegate: Loader {
        required property var modelData

        asynchronous: true
        Layout.alignment: Qt.AlignHCenter
        Layout.fillHeight: true
        Layout.fillWidth: true

        source: {
            const component = (vertical ? BarData.contentTable[modelData] : BarData.horizontalSubstitutions[modelData]) ?? BarData.contentTable[modelData];
            return component ? component + ".qml" : "";
        }
        onLoaded: if (item) {
            BarData.layoutProps.forEach(prop => {
                Layout[prop] = Qt.binding(() => item?.Layout?.[prop]);
            });

            if ("bar" in item)
                item.bar = barRoot;
            if ("verticalMode" in item)
                item.verticalMode = root.vertical;
            if ("vertical" in item)
                item.vertical = root.vertical;
        }
    }
}
