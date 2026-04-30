import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.store
import qs.common
import qs.common.widgets

Item {
    id: root
    anchors.fill: parent
    property var visibleData
    property var itemStates
    property alias query: searchbar.text

    ApplicationSearchBar {
        id: searchbar
        z: 999999
        width: Math.min(parent.width - 40, 500)
        visible: true
    }

    PagePlaceholder {
        anchors.centerIn: parent
        shown: root.visibleData.length === 0 && !selectedCatData.isPage
        title: "No Results Found"
        icon: "search_off"
        description: root.debouncedQuery !== "" ? "No settings match '" + searchbar.query + "'" : "This category is currently empty."
    }

    StyledFlickable {
        id: scrollArea
        z: 0
        anchors.fill: parent
        anchors.topMargin: searchbar.height + Padding.large
        contentHeight: contentColumn.implicitHeight + 100
        clip: true

        MouseArea {
            anchors.fill: parent
            onClicked: root.forceActiveFocus()
            z: -1
        }

        StyledListView {
            anchors.fill: parent
            spacing: Padding.massive
            animateMovement: false
            popin: false
            hint: false
            _model: root.visibleData

            delegate: ColumnLayout {
                required property var modelData
                required property int index
                anchors.right: parent?.right
                anchors.left: parent?.left
                spacing: Padding.massive

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
                            columnSpacing: Padding.large
                            rowSpacing: Padding.large
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
                                    required property var modelData
                                    required property int index
                                    icon: modelData?.icon ?? "settings"
                                    name: modelData?.name ?? ""
                                    key: modelData?.key ?? ""
                                    type: modelData?.type ?? "switch"
                                    hint: modelData?.hint ?? ""
                                    useStates: modelData?.state ?? false
                                    sliderMinValue: modelData?.sliderMinValue ?? 0.0
                                    sliderMaxValue: modelData?.sliderMaxValue ?? 100.0
                                    reloadOnChange: modelData?.reloadOnChange ?? false
                                    actionName: modelData?.actionName ?? ""
                                    comboBoxValues: modelData?.comboBoxValues ?? []
                                    fillHeight: modelData?.fillHeight ?? false
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: Rounding.normal
                                    visible: modelData?.visible ?? true
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
