import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.store
import qs.common
import qs.common.widgets

Item {
    id: root
    focus: true
    required property var window

    property string debouncedQuery: ""

    Timer {
        id: debounceTimer
        interval: 200
        repeat: false
        onTriggered: root.debouncedQuery = searchbar.query.toLowerCase()
    }

    readonly property string selectedCat: Mem?.states?.applications?.settings?.cat ?? "Appearance"

    readonly property var _visible_data: {
        const tweaks = SettingsData?.tweaks ?? [];
        const result = [];
        const q = root.debouncedQuery;

        for (let i = 0; i < tweaks.length; i++) {
            const sec = tweaks[i];
            const filtered = (sec.items || []).filter(item => {
                const match = (item.name || "").toLowerCase().includes(q);
                return q !== "" ? match : (sec.section === selectedCat && match);
            });
            if (filtered.length > 0)
                result.push({
                    "section": sec.section,
                    "icon": sec.icon,
                    "items": filtered,
                    "shell": sec.shell
                });
        }
        return result;
    }

    property var itemStates: ({})

    Keys.onPressed: event => {
        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_F) {
            searchbar.visible = !searchbar.visible;
            searchbar.inputArea.forceActiveFocus();
            event.accepted = true;
        }
    }

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: Colors.colLayer0

        StyledFlickable {
            id: scrollArea
            anchors.fill: parent
            contentHeight: contentColumn.implicitHeight
            clip: true

            MouseArea {
                anchors.fill: parent
                onClicked: root.forceActiveFocus()
                z: -1
            }

            ColumnLayout {
                id: contentColumn
                width: parent.width
                spacing: 20

                Repeater {
                    model: root._visible_data
                    delegate: ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        RowLayout {
                            Layout.margins: Padding.large
                            Layout.fillWidth: true
                            spacing: 10
                            // visible: root.debouncedQuery !== ""
                            Symbol {
                                text: modelData.icon || ""
                                color: Colors.colPrimary
                                font.pixelSize: 32
                            }
                            ColumnLayout {
                                spacing:0
                                StyledText {
                                    text: modelData.section || ""
                                    color: Colors.colOnLayer0
                                    font.pixelSize: 14
                                }
                                StyledText {
                                    text: ("Available For " + modelData.shell) || ""
                                    color: Colors.colSubtext
                                    font.pixelSize: 12
                                }

                            }
                        }

                        GridLayout {
                            columns: {
                                if (root.width > 1100)
                                    return 4;
                                if (root.width > 800)
                                    return 3;
                                if (root.width > 550)
                                    return 2;
                                return 1;
                            }
                            Layout.fillWidth: true
                            Layout.margins: 10
                            columnSpacing: 10
                            rowSpacing: 10

                            Repeater {
                                model: modelData.items
                                delegate: SettingsItem {
                                    Layout.fillWidth: true
                                    colors: Colors
                                    name: modelData.name || "Unknown"
                                    key: modelData.key || ""
                                    icon: modelData.icon || "settings"
                                    type: modelData.type || "button"
                                    comboBoxValues: modelData.comboBoxValues || []
                                    onToggledStateChanged: if (key)
                                        root.itemStates[key] = toggledState
                                    onIntValueChanged: if (key)
                                        root.itemStates[key] = intValue
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ApplicationSearchBar {
        id: searchbar
        visible: true
        onQueryChanged: debounceTimer.restart()
    }

    PagePlaceholder {
        anchors.centerIn: parent
        shown: root._visible_data.length === 0
        title: "Empty"
        icon: "tune"
        description: root.debouncedQuery !== "" ? "No match for: " + searchbar.query : "No items in " + selectedCat
    }
}
