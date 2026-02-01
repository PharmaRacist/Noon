import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.modules.main.bar.components
import qs.services
import qs.store

ColumnLayout {
    id: root
    required property var barRoot

    spacing: Padding.normal

    anchors {
        fill: parent
        topMargin: Padding.huge
        bottomMargin: Padding.huge
    }

    Repeater {
        model: Mem.options.bar.vMap ?? []

        delegate: Loader {
            id: moduleLoader
            required property var modelData

            asynchronous: true
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            Layout.fillWidth: true

            source: {
                const component = BarData.contentTable[modelData];
                return component ? "../../components/" + component + ".qml" : "";
            }

            onLoaded: if (item) {
                BarData.layoutProps.forEach(prop => {
                    Layout[prop] = Qt.binding(() => item?.Layout?.[prop]);
                });

                if ("bar" in item)
                    item.bar = barRoot;
                if ("verticalMode" in item)
                    item.verticalMode = true;
                if ("vertical" in item)
                    item.vertical = true;
            }
        }
    }
}
