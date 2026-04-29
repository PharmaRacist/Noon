import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.store
import qs.common
import qs.common.widgets

Item {
    anchors.fill: parent

    ApplicationSearchBar {
        id: searchbar
        z: 999999
        width: Math.min(parent.width - 40, 500)
        visible: true
        onQueryChanged: debounceTimer.restart()
    }

    PagePlaceholder {
        anchors.centerIn: parent
        shown: root._visible_data.length === 0 && !selectedCatData.isPage
        title: "No Results Found"
        icon: "search_off"
        description: root.debouncedQuery !== "" ? "No settings match '" + searchbar.query + "'" : "This category is currently empty."
    }

    StyledFlickable {
        id: scrollArea
        z: 0
        anchors.fill: parent
        anchors.topMargin: Padding.massive
        contentHeight: contentColumn.implicitHeight + 100
        clip: true

        MouseArea {
            anchors.fill: parent
            onClicked: root.forceActiveFocus()
            z: -1
        }

        ColumnLayout {
            id: contentColumn
            width: parent.width
            spacing: 40

            Repeater {
                model: root._visible_data
                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    RowLayout {
                        Layout.leftMargin: Padding.large
                        Layout.rightMargin: Padding.large
                        Layout.fillWidth: true
                        spacing: 15

                        Symbol {
                            text: modelData.icon || "settings"
                            color: Colors.colPrimary
                            font.pixelSize: 32
                        }

                        ColumnLayout {
                            spacing: 0
                            StyledText {
                                text: modelData.section || ""
                                color: Colors.colOnLayer0
                                font.pixelSize: 18
                                font.bold: true
                            }
                            StyledText {
                                text: "Shell Context: " + (modelData.shell || "Global")
                                color: Colors.colSubtext
                                font.pixelSize: 11
                                opacity: 0.7
                            }
                        }
                    }

                    Repeater {
                        model: modelData.subsections
                        delegate: ColumnLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: Padding.large + 10
                            Layout.rightMargin: Padding.large
                            spacing: 12

                            StyledText {
                                text: (modelData.name || "General").toUpperCase()
                                color: Colors.colPrimary
                                font.pixelSize: 13
                                font.letterSpacing: 1.5
                                font.weight: 900
                                font.family: Fonts.family.monospace
                                opacity: 0.9
                            }

                            GridLayout {
                                id: itemsGrid
                                Layout.fillWidth: true
                                columnSpacing: 12
                                rowSpacing: 12
                                columns: {
                                    if (root.width > 1200)
                                        return 4;
                                    if (root.width > 900)
                                        return 3;
                                    if (root.width > 600)
                                        return 2;
                                    return 1;
                                }

                                Repeater {
                                    model: modelData.items
                                    delegate: SettingsItem {
                                        Layout.fillWidth: true
                                        fillHeight: modelData.fillHeight || false
                                        colors: Colors
                                        name: modelData.name || "Unknown"
                                        key: modelData.key || ""
                                        icon: modelData.icon || "settings"
                                        type: modelData.type || "switch"
                                        comboBoxValues: modelData.comboBoxValues || []
                                        radius: Rounding.normal
                                        onToggledStateChanged: if (key) {
                                            root.itemStates[key] = toggledState;
                                        }
                                        onIntValueChanged: if (key) {
                                            root.itemStates[key] = intValue;
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.preferredHeight: 10
                            }
                        }
                    }
                }
            }
        }
    }
}
