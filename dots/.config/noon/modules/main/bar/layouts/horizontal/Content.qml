import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.modules.main.bar.components
import qs.services
import qs.store

RowLayout {
    id: root
    required property var barRoot

    spacing: Mem.options.bar.spacing ?? 5

    anchors {
        fill: parent
        rightMargin: Padding.huge
        leftMargin: Padding.huge
    }

    Repeater {
        model: Mem.options.bar.hMap ?? []

        delegate: Loader {
            id: moduleLoader
            required property var modelData

            asynchronous: true
            Layout.alignment: Qt.AlignVCenter

            source: {
                const component = BarData.horizontalSubstitutions[modelData] ?? BarData.contentTable[modelData];
                return component ? "../../components/" + component + ".qml" : "";
            }

            onLoaded: if (item) {
                BarData.layoutProps.forEach(prop => {
                    Layout[prop] = Qt.binding(() => item?.Layout?.[prop]);
                });

                if ("bar" in item)
                    item.bar = barRoot;
                if ("verticalMode" in item)
                    item.verticalMode = false;
                if ("vertical" in item)
                    item.vertical = false;
            }
        }
    }
}
