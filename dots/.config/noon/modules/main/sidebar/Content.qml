import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services
import qs.store

import "./components/apis"
import "./components/beats"
import "./components/gallary"
import "./components/games"
import "./components/misc"
import "./components/notes"
import "./components/notifs"
import "./components/polkit"
import "./components/session"
import "./components/settings"
import "./components/tasks"
import "./components/view"
import "./components/wallpapers"
import "./components/shelf"
import "./components/widgets"
import "./components/web"

Item {
    id: root

    anchors.fill: parent
    anchors.margins: Padding.large
    clip: true
    focus: true

    Keys.onPressed: event => handleRootKeys(event)

    property bool showContent: false
    property bool rightMode: true
    property string searchText: ""
    property string selectedCategory: ""
    property bool expanded: false
    property bool _manualExpandedToggle: false
    property bool effectiveSearchable: SidebarData.isSearchable(selectedCategory)
    property bool pinned: false

    property QtObject colors: {
        if (SidebarData.isColorful(selectedCategory)) {
            if (selectedCategory === "Beats")
                return BeatsService.colors;
            if (selectedCategory === "Games")
                return GameLauncherService.colors;
        }
        return Colors;
    }

    required property var panelWindow

    property bool auxVisible: false
    property string auxCategory: ""
    property string auxSearchText: ""

    signal requestPin
    signal barLayoutChangeRequested(int layoutIndex, bool isVertical)
    signal appLaunched(var app)
    signal contentToggleRequested

    function focusMainSearchInput() {
        const mainPanel = panelRepeater.itemAt(0);
        if (mainPanel && mainPanel.searchInput && effectiveSearchable)
            mainPanel.searchInput.forceActiveFocus();
    }

    function auxReveal(categoryKey) {
        const isAvailable = SidebarData.enabledCategories.includes(categoryKey) || SidebarData.isStealth(categoryKey);
        if (!categoryKey || !isAvailable)
            return;

        if (auxCategory === categoryKey && auxVisible) {
            resetAux();
            return;
        }
        auxCategory = categoryKey;
        auxSearchText = "";
        auxVisible = true;
    }

    function resetAux() {
        auxVisible = false;
        auxCategory = "";
        auxSearchText = "";
    }
    function dismiss() {
        selectedCategory = "";
        GlobalStates.main.sidebar.hoverMode = true;
    }
    function changeContent(newCategoryKey) {
        if (newCategoryKey === "")
            return;

        if (selectedCategory === newCategoryKey && selectedCategory !== "") {
            dismiss();
            return;
        }

        if (!panelWindow.show) {
            panelWindow.hoverMode = false;
        }

        resetSearch();
        selectedCategory = newCategoryKey;
    }

    function resetSearch() {
        root.searchText = "";
    }

    function handleRootKeys(event) {
        const key = event.key;
        const mods = event.modifiers;

        if (key === Qt.Key_Escape) {
            dismiss();
            event.accepted = true;
            return true;
        }

        if (key === Qt.Key_Tab || key === Qt.Key_Backtab) {
            const isBack = (mods === Qt.ShiftModifier || mods === (Qt.ControlModifier | Qt.ShiftModifier));
            const target = isBack ? SidebarData.getPreviousEnabledCategory(selectedCategory) : SidebarData.getNextEnabledCategory(selectedCategory);

            if (target) {
                changeContent(target);
                event.accepted = true;
                return true;
            }
        }

        if (mods === Qt.ControlModifier) {
            if (key === Qt.Key_O && SidebarData.isExpandable(selectedCategory)) {
                if (!(auxVisible && expanded)) {
                    _manualExpandedToggle = true;
                    expanded = !expanded;
                }
                event.accepted = true;
                return true;
            } else if (key === Qt.Key_P) {
                Qt.callLater(() => requestPin());
                event.accepted = true;
                return true;
            } else if (key === Qt.Key_Q) {
                Qt.callLater(() => resetAux());
                event.accepted = true;
                return true;
            } else if (key === Qt.Key_R && selectedCategory === "History") {
                ClipboardService.wipe();
                event.accepted = true;
                return true;
            }
        }

        if (mods === Qt.ControlModifier && selectedCategory === "Walls") {
            const mainPanelItem = panelRepeater.itemAt(0);
            const loader = mainPanelItem ? mainPanelItem.children[mainPanelItem.children.length - 2] : null;
            const view = loader ? loader.item : null;
            if (view) {
                if (key === Qt.Key_Left)
                    WallpaperService.goBack();
                else if (key === Qt.Key_S && typeof view.shuffleWallpapers === 'function')
                    view.shuffleWallpapers();
                event.accepted = true;
                return true;
            }
        }
        return false;
    }

    onEffectiveSearchableChanged: focusMainSearchInput()
    onSelectedCategoryChanged: resetSearch()
    onAuxCategoryChanged: resetAux()

    Binding {
        target: root
        property: "expanded"
        value: auxVisible || (SidebarData.usePreExpand(selectedCategory) && SidebarData.isExpandable(selectedCategory))
        when: !_manualExpandedToggle
    }

    Connections {
        target: PolkitService
        function onFlowChanged() {
            if (PolkitService.flow !== null) {
                if (!showContent)
                    panelWindow.if(selectedCategory !== "Auth");
                changeContent("Auth");
                focusMainSearchInput();
            } else
                root.dismiss();
        }
    }

    RowLayout {
        anchors.fill: parent
        layoutDirection: rightMode ? Qt.RightToLeft : Qt.LeftToRight
        spacing: Padding.large

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            layoutDirection: !root.rightMode ? Qt.LeftToRight : Qt.RightToLeft

            SidebarNavigationRail {
                selectedCategory: root.selectedCategory
                colors: root.colors
            }

            Repeater {
                id: panelRepeater
                model: 2
                visible: root.showContent

                ContentChild {
                    required property int index
                    colors: root.colors
                    showContent: root.showContent
                    Layout.fillHeight: true
                    Layout.fillWidth: index === 0
                    Layout.preferredWidth: SidebarData.sizePresets.contentQuarter
                    Layout.margins: visible ? Padding.normal : 0
                    Layout.maximumWidth: isAux ? SidebarData.sizePresets.contentQuarter : Number.POSITIVE_INFINITY

                    visible: index === 0 ? (selectedCategory !== "") : auxVisible
                    category: index === 0 ? selectedCategory : auxCategory
                    searchText: index === 0 ? root.searchText : auxSearchText
                    componentPath: index === 0 ? SidebarData.getComponentPath(selectedCategory) : SidebarData.getComponentPath(auxCategory)

                    parentRoot: root
                    isAux: index === 1
                    effectiveSearchable: index === 0 ? root.effectiveSearchable : SidebarData.isSearchable(auxCategory)

                    onSearchUpdated: newText => {
                        if (category === "Web")
                            return;
                        if (index === 0)
                            root.searchText = newText;
                        else
                            root.auxSearchText = newText;
                    }

                    Behavior on Layout.preferredWidth {
                        Anim {}
                    }
                }
            }
        }
    }
}
