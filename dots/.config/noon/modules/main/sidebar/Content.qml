import Noon
import QtQuick
import QtQuick.Layouts
import Quickshell
import "components/apis"
import "components/beats"
import "components/games"
import "components/misc"
import "components/notes"
import "components/notifs"
import "components/polkit"
import "components/session"
import "components/settings"
import "components/shelf"
import "components/tasks"
import "components/view"
import "components/wallpapers"
import "components/web"
import "components/widgets"
import qs.common
import qs.common.widgets
import qs.services
import qs.store

Item {
    id: root

    required property var panelWindow
    readonly property bool effectiveSearchable: SidebarData.isSearchable(selectedCategory) ?? false
    property QtObject colors: SidebarData.getColors(selectedCategory) || Colors
    property bool auxVisible: false
    property string selectedCategory: ""
    property string auxCategory: ""
    property string auxSearchText: ""

    function focusMainSearchInput() {
        if (main_child && main_child.searchInput && effectiveSearchable)
            main_child.searchInput.forceActiveFocus();

    }

    function changeContent(newCategoryKey) {
        if (!newCategoryKey || !SidebarData.enabledCategories.includes(newCategoryKey) && !SidebarData.isStealth(newCategoryKey))
            return ;

        if (selectedCategory === newCategoryKey) {
            panelWindow.hide();
            return ;
        }
        if (!panelWindow.show)
            panelWindow.hoverMode = false;

        selectedCategory = newCategoryKey;
    }

    function toggleAux(categoryKey) {
        const enabled = SidebarData.enabledCategories.includes(categoryKey);
        if (!categoryKey || !enabled || categoryKey === "")
            return ;

        if (auxVisible && auxCategory === categoryKey) {
            closeAux();
            return ;
        }
        openAux(categoryKey);
    }

    function openAux(cat) {
        auxSearchText = "";
        auxCategory = cat;
        auxVisible = true;
    }

    function closeAux() {
        auxVisible = false;
        auxCategory = "";
        auxSearchText = "";
    }

    anchors.fill: parent
    anchors.margins: Padding.large
    clip: true
    focus: true
    onAuxCategoryChanged: toggleAux()
    onEffectiveSearchableChanged: {
        if (effectiveSearchable) {
            focusMainSearchInput();
        }
    }
    Keys.onPressed: (event) => {
        const key = event.key;
        const mods = event.modifiers;
        const isCtrl = (mods === Qt.ControlModifier);
        if (key === Qt.Key_Slash) {
            focusMainSearchInput();
        } else if (key === Qt.Key_Escape) {
            dismiss();
        } else if (key === Qt.Key_Tab || key === Qt.Key_Backtab) {
            const isBack = (mods === Qt.ShiftModifier || mods === (Qt.ControlModifier | Qt.ShiftModifier));
            const target = isBack ? SidebarData.getPreviousEnabledCategory(selectedCategory) : SidebarData.getNextEnabledCategory(selectedCategory);
            if (target)
                changeContent(target);

        } else if (isCtrl) {
            switch (key) {
            case Qt.Key_O:
                if (SidebarData.isExpandable(selectedCategory) && !auxVisible)
                    root.panelWindow.expanded = !root.panelWindow.expanded;

                break;
            case Qt.Key_P:
                root.panelWindow.pinned = !root.panelWindow.pinned;
                break;
            case Qt.Key_Q:
                Qt.callLater(() => {
                    return closeAux();
                });
                break;
            case Qt.Key_R:
                if (selectedCategory === "History")
                    ClipboardService.wipe();

                break;
            default:
                return false;
            }
        } else {
            return false;
        }
        event.accepted = true;
        return true;
    }

    Connections {
        function onFlowChanged() {
            if (PolkitService.flow !== null)
                changeContent("Auth");
            else
                root.panelWindow.hide();
        }

        target: PolkitService
    }

    RowLayout {
        anchors.fill: parent
        layoutDirection: panelWindow.rightMode ? Qt.RightToLeft : Qt.LeftToRight
        spacing: Padding.large

        SidebarNavigationRail {
            selectedCategory: root.selectedCategory
            colors: root.colors
        }

        ContentChild {
            id: main_child

            Layout.maximumWidth: root.auxVisible ? SidebarData.currentSize(false, false, category) : Sizes.infinity
            _aux: false
            category: selectedCategory
        }

        VerticalSeparator {
            visible: root.auxVisible
        }

        Loader {
            id: aux_loader

            visible: active
            active: root.auxVisible
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: SidebarData.currentSize(false, false, category)
            onLoaded: {
                if (item) {
                    if ("parentRoot" in item)
                        item.parentRoot = Qt.binding(() => {
                        return root;
                    });

                    if ("category" in item)
                        item.category = Qt.binding(() => {
                        return root.auxCategory;
                    });

                }
            }

            sourceComponent: ContentChild {
                anchors.fill: parent
                _aux: true
                category: auxCategory
            }

        }

    }

}
