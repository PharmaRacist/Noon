import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services
import qs.store

StyledRect {
    id: root
    color: "transparent"
    radius: Rounding.verylarge

    property string searchQuery: ""
    readonly property bool isVerticalBar: BarData.position === "left" || BarData.position === "right"

    signal searchFocusRequested
    signal contentFocusRequested
    signal dismiss

    onContentFocusRequested: listView.forceActiveFocus()

    ScriptModel {
        id: barModel
        values: {
            const currentLayout = Mem.options.bar.layout;
            const query = root.searchQuery.toLowerCase().trim();

            return BarData.bars.filter(name => !query || name.toLowerCase().includes(query)).map(name => {
                const isVertical = name[0] === name[0].toUpperCase() && name.startsWith("V");
                const isActive = currentLayout === name;

                return {
                    name: `${name} (${isVertical ? 'Vertical' : 'Horizontal'})`,
                    displayName: name,
                    icon: isActive ? "check" : "",
                    type: qsTr(isVertical ? "Vertical Layout" : "Horizontal Layout"),
                    isActive: isActive,
                    layoutName: name,
                    isVertical: isVertical
                };
            });
        }
    }

    StyledListView {
        id: listView
        anchors.fill: parent
        anchors.margins: Padding.normal
        spacing: Padding.small
        model: barModel

        delegate: StyledDelegateItem {
            width: listView.width
            required property var modelData
            required property int index

            title: modelData.name
            subtext: modelData.type
            materialIcon: modelData.icon
            toggled: listView.currentIndex === index
            highlighted: modelData.isActive

            releaseAction: () => {
                root.dismiss();
                // Set layout and adjust position if needed
                Mem.options.bar.layout = modelData.layoutName;

                // If switching orientation, update position appropriately
                if (modelData.isVertical && !root.isVerticalBar) {
                    Mem.options.bar.behavior.position = "left";
                } else if (!modelData.isVertical && root.isVerticalBar) {
                    Mem.options.bar.behavior.position = "top";
                }
            }
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Up && currentIndex <= 0) {
                root.searchFocusRequested();
            } else if (event.key === Qt.Key_Down && currentIndex < count - 1) {
                currentIndex++;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (currentIndex >= 0) {
                    const data = model.values[currentIndex];
                    Mem.options.bar.layout = data.layoutName;

                    // Adjust position if switching orientation
                    if (data.isVertical && !root.isVerticalBar) {
                        Mem.options.bar.behavior.position = "left";
                    } else if (!data.isVertical && root.isVerticalBar) {
                        Mem.options.bar.behavior.position = "top";
                    }

                    root.dismiss();
                }
            } else {
                return;
            }
            event.accepted = true;
        }
    }
}
