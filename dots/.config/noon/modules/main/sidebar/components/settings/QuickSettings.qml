import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import QtQuick.Controls
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.store
import qs.services
import qs.common
import qs.common.widgets

StyledRect {
    id: root
    z: 1
    clip: true
    color:"transparent"
    radius: Rounding.verylarge
    property int rowHeight: 30
    property int padding: Padding.normal
    property int minItemWidth: 300
    property int itemSpacing: Padding.normal
    property QtObject colors: Colors

    property int columnNumber: {
        var availableWidth = width - (padding * 2);
        var effectiveItemWidth = minItemWidth + itemSpacing;
        var calculatedColumns = Math.floor(availableWidth / effectiveItemWidth);
        return Math.max(1, calculatedColumns);
    }

    property string searchQuery: ""
    property bool expanded:  false
    Layout.fillWidth: true
    Layout.fillHeight: true

    signal expandToggled

    property var settingsData: SettingsData.tweaks.settingsData ?? []
    property var itemStates: ({})

    function matchesSearch(text) {
        return searchQuery === "" || text.toLowerCase().includes(searchQuery.toLowerCase());
    }

    function shouldShowItem(item) {
        var searchMatch = matchesSearch(item.name);
        if (!searchMatch)
            return false;

        if (item.condition) {
            try {
                return eval(item.condition);
            } catch (e) {
                return false;
            }
        }

        if (item.dependsOn) {
            return (root.itemStates[item.dependsOn] ?? false) === true;
        }

        return true;
    }

    property bool hasAnyVisibleSettingsItem: {
        for (var i = 0; i < settingsData.length; i++) {
            var section = settingsData[i];
            if (section.items) {
                for (var j = 0; j < section.items.length; j++) {
                    if (shouldShowItem(section.items[j])) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    Timer {
        id: reloadTimeOut
        interval: 200
        onTriggered: Quickshell.reload(true)
    }

    PagePlaceholder {
        anchors.centerIn:parent
        visible: !root.hasAnyVisibleSettingsItem
        icon:  "block"
        shape:MaterialShape.Clover4Leaf
        title:  "Nothing found"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 5

        StyledFlickable {
            Layout.fillHeight: true
            Layout.fillWidth: true
            contentHeight: contentColumn.height
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            ColumnLayout {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 7

                Repeater {
                    model: settingsData

                    delegate: Column {
                        Layout.fillWidth: true

                        property bool hasVisibleItems: {
                            if (!modelData.items)
                                return false;
                            for (var i = 0; i < modelData.items.length; i++) {
                                if (shouldShowItem(modelData.items[i])) {
                                    return true;
                                }
                            }
                            return false;
                        }

                        visible: hasVisibleItems

                        StyledText {
                            text: modelData?.section ?? ""
                            width: parent.width
                            leftPadding: 15
                            bottomPadding: 5
                            topPadding: index > 0 ? 10 : 0
                            color: root.colors.colSubtext
                            font.pixelSize: Fonts.sizes.small
                            font.weight: 600
                            visible: parent.hasVisibleItems
                        }

                        GridLayout {
                            width: parent.width
                            columns: root.columnNumber
                            columnSpacing: 10
                            rowSpacing: 5

                            Repeater {
                                model: modelData.items

                                delegate: SettingsItem {
                                    icon: modelData?.icon ?? "settings"
                                    name: modelData?.name ?? ""
                                    key: modelData?.key ?? ""
                                    type: modelData?.type ?? "button"
                                    hint: modelData?.hint ?? ""
                                    useStates:modelData?.state ?? false
                                    enableTooltip:modelData?.enableTooltip ?? true
                                    textPlaceholder:modelData?.textPlaceholder ?? ""
                                    sliderMinValue: modelData?.sliderMinValue ?? 0.0
                                    sliderMaxValue: modelData?.sliderMaxValue ?? 100.0
                                    sliderValue: modelData?.sliderValue ?? 0.5
                                    reloadOnChange:modelData?.reloadOnChange ?? false
                                    customItemHeight:modelData?.customItemHeight ?? 65
                                    actionName: modelData?.actionName ?? ""
                                    itemValue: modelData?.itemValue ?? 0
                                    subOption: modelData?.subOption ?? false
                                    comboBoxValues: modelData?.comboBoxValues ?? []
                                    fillHeight:modelData?.fillHeight ?? false
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    visible: (modelData?.visible ?? true) && shouldShowItem(modelData)
                                    property bool isSearchMatch: root.searchQuery !== "" && matchesSearch(modelData.name)
                                    colors:root.colors
                                    Rectangle {
                                        anchors.fill: parent
                                        color: root.colors.colPrimary
                                        opacity: parent.isSearchMatch ? 0.1 : 0
                                        radius: 8
                                        z: -1

                                        Behavior on opacity {
                                            Anim {}
                                        }
                                    }

                                    onToggledStateChanged: {
                                        if (modelData.key) {
                                            root.itemStates[modelData.key] = toggledState;
                                        }
                                    }

                                    onIntValueChanged: {
                                        if (modelData.key) {
                                            root.itemStates[modelData.key] = intValue;
                                        }
                                    }

                                    Component.onCompleted: {
                                        if (modelData.key) {
                                            if (type === "spin") {
                                                root.itemStates[modelData.key] = intValue;
                                            } else {
                                                root.itemStates[modelData.key] = toggledState;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
