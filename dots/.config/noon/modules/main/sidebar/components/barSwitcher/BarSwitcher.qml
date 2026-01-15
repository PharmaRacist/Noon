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
    readonly property bool isVerticalBar: Mem.options.bar.behavior.position === "left" || Mem.options.bar.behavior.position === "right"

    signal searchFocusRequested
    signal contentFocusRequested
    signal dismiss
    onContentFocusRequested: listView.forceActiveFocus();
    ScriptModel {
        id: barModel
        values: {
            const allLayouts = [];
            const process = (layouts, isVert) => {
                const currentIdx = isVert ? Mem.options.bar.currentVerticalLayout : Mem.options.bar.currentLayout;
                const isTypeActive = isVert ? root.isVerticalBar : !root.isVerticalBar;

                layouts.forEach((layout, idx) => {
                    const name = layout.replace('Layout', '');
                    const isActive = isTypeActive && currentIdx === idx;

                    allLayouts.push({
                        name: `${name} (${isVert ? 'Vertical' : 'Horizontal'})`,
                        displayName: name,
                        icon: isActive ? "check" : "",
                        type: isVert ? qsTr("Vertical Layout") : qsTr("Horizontal Layout"),
                        isActive: isActive,
                        layoutIndex: idx,
                        isVertical: isVert
                    });
                });
            };

            process(BarData.horizontalLayouts, false);
            process(BarData.verticalLayouts, true);

            const query = root.searchQuery.trim();
            if (!query)
                return allLayouts;

            const results = Fuzzy.go(query, allLayouts, {
                key: 'name',
                threshold: -5000
            });
            return results.map(r => r.obj);
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

            title: modelData.name
            subtext: modelData.type
            materialIcon: modelData.icon
            toggled: listView.currentIndex === index
            highlighted: modelData.isActive

            releaseAction: () => {
                root.dismiss();
                BarData.switchBarLayout(modelData.layoutIndex, modelData.isVertical);
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
                    BarData.switchToLayout(data.layoutIndex, data.isVertical);
                    root.dismiss();
                }
            } else
                return;
            event.accepted = true;
        }
    }
}
