import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.common.functions
import qs.common.utils
import qs.common.widgets
import qs.services
import qs.store

StyledPanel {
    id: root
    name: "sidebar"
    visible: true

    property bool pinned: GlobalStates.main.sidebar.pinned
    property bool barMode: true
    property bool seekOnSuper: Mem.options.sidebar.behavior.superHeldReveal
    property int sidebarWidth: SidebarData.currentSize(barMode, sidebarContent.expanded, sidebarContent.selectedCategory) + (sidebarContent.auxVisible && !barMode ? SidebarData.sizePresets.contentQuarter : 0)
    property bool reveal: (hoverArea.containsMouse && barMode) || _isTransitioning || (seekOnSuper ? GlobalStates.superHeld : null) || PolkitService.flow !== null
    property bool _isTransitioning: false
    property bool noExlusiveZone: {
        if (!pinned) {
            if (Mem.options.bar.appearance.mode === 0 && Mem.options.bar.behavior.position === "top" || Mem.options.bar.behavior.position === "bottom") {
                return true;
            }
            if (Mem.options.bar.behavior.position === "left" || Mem.options.bar.behavior.position === "right") {
                return true;
            }
        }
        return false;
    }

    implicitWidth: visualContainer.width + visualContainer.rounding
    exclusiveZone: !barMode && pinned ? implicitWidth - visualContainer.rounding : noExlusiveZone ? -1 : 0
    aboveWindows: true
    kbFocus: GlobalStates.main.sidebar.show && !barMode
    WlrLayershell.layer: SidebarData?.isOverlay(sidebarContent.selectedCategory) ? WlrLayer.Overlay : WlrLayer.Top

    anchors {
        left: !visualContainer.rightMode || !pinned
        top: true
        right: visualContainer.rightMode || !pinned
        bottom: true
    }

    function hideSidebar() {
        if (_isTransitioning && pinned)
            return;

        _isTransitioning = true;
        reveal = true;
        finalizeHide();
    }

    function showSidebar() {
        if (_isTransitioning)
            return;

        barMode = false;
        GlobalStates.main.sidebar.show = true;
        GlobalStates.main.sidebar.expanded = true;
        sidebarContent.forceActiveFocus();
    }

    function finalizeHide() {
        _isTransitioning = false;
        barMode = true;
        GlobalStates.main.sidebar.expanded = false;

        if (!pinned) {
            reveal = Qt.binding(() => (hoverArea.containsMouse && barMode) || _isTransitioning || (seekOnSuper ? GlobalStates.superHeld : null) || PolkitService.flow !== null);
        }

        if (sidebarContent.clearSearch)
            sidebarContent.clearSearch();
    }

    function togglePin() {
        GlobalStates.main.sidebar.pinned = !pinned;
    }

    Binding {
        target: SidebarData
        property: "sidebarWidth"
        value: sidebarWidth
    }

    Binding {
        target: GlobalStates.main
        property: "show"
        value: !barMode
    }

    Item {
        id: interactiveContainer

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: !visualContainer.rightMode ? parent.left : undefined
            right: visualContainer.rightMode ? parent.right : undefined
        }

        // Only consume width when revealed or not in bar mode
        width: {
            if (!barMode) {
                return visualContainer.width + (bubble.visible ? bubble.width + Padding.verylarge * 2 : 0);
            } else if (reveal) {
                return Math.max(visualContainer.width, hoverArea.width);
            } else {
                return Sizes.hyprland.gapsOut + Sizes.hyprland.gapsIn;
            }
        }

        Behavior on width {
            Anim {}
        }
        MouseArea {
            id: hoverArea
            enabled: barMode
            z: 1000
            hoverEnabled: true
            acceptedButtons: Qt.NoButton

            width: reveal ? visualContainer.width : Sizes.hyprland.gapsOut + Sizes.hyprland.gapsIn
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: !visualContainer.rightMode ? parent.left : undefined
                right: visualContainer.rightMode ? parent.right : undefined
            }
            DropArea {
                anchors.fill: parent
                keys: ["text/uri-list"]
                onEntered: Noon.callIpc("sidebar reveal Shelf")
                onExited: () => {}
            }
        }

        StyledRectangularShadow {
            target: visualContainer
        }

        StyledRect {
            id: visualContainer

            property bool rightMode: Mem.options.bar.behavior.position === "left" || Mem.options.bar.behavior.position === "top"
            property int mode: Mem.options.sidebar.appearance.mode
            property int rounding: Rounding.verylarge

            width: sidebarWidth
            color: sidebarContent.contentColor

            topRightRadius: !rightMode && mode === 1 ? rounding : 0
            bottomRightRadius: !rightMode && mode === 1 ? rounding : 0
            topLeftRadius: rightMode && mode === 1 ? rounding : 0
            bottomLeftRadius: rightMode && mode === 1 ? rounding : 0

            anchors {
                top: parent.top
                bottom: parent.bottom
                left: !rightMode ? parent.left : undefined
                right: rightMode ? parent.right : undefined
                leftMargin: !rightMode ? ((!barMode || reveal) ? -1 : -(width - 1)) : 0
                rightMargin: rightMode ? ((!barMode || reveal) ? -1 : -(width - 1)) : 0
                topMargin: mode === 1 && Mem.options.bar.behavior.position !== "top" ? Sizes.frameThickness : 0
                bottomMargin: mode === 1 && Mem.options.bar.behavior.position !== "bottom" ? Sizes.frameThickness : 0
            }

            Content {
                id: sidebarContent
                rightMode: visualContainer.rightMode
                panelWindow: root
                showContent: !barMode
                pinned: root.pinned
                onRequestPin: root.togglePin()
            }

            Behavior on anchors.leftMargin {
                Anim {
                    duration: Animations.durations.small
                    easing.bezierCurve: Animations.curves.emphasized
                }
            }

            Behavior on anchors.rightMargin {
                Anim {
                    duration: Animations.durations.small
                    easing.bezierCurve: Animations.curves.emphasized
                }
            }

            Behavior on width {
                Anim {
                    duration: Animations.durations.normal
                    easing.bezierCurve: Animations.curves.emphasized
                }
            }

            Behavior on color {
                CAnim {
                    duration: Animations.durations.verylarge
                    easing.bezierCurve: Animations.curves.emphasized
                }
            }

            Behavior on radius {
                FAnim {
                    duration: Animations.durations.normal
                    easing.bezierCurve: Animations.curves.emphasized
                }
            }
        }

        SidebarBubble {
            id: bubble
            show: !barMode
            rightMode: visualContainer.rightMode
            selectedCategory: sidebarContent.selectedCategory
            colors: sidebarContent.colors
            anchors {
                right: !visualContainer.rightMode ? undefined : visualContainer.left
                left: visualContainer.rightMode ? undefined : visualContainer.right
                bottom: visualContainer.bottom
                margins: Padding.verylarge
            }
        }

        RoundCorner {
            id: c1
            visible: visualContainer.mode === 2
            corner: visualContainer.rightMode ? cornerEnum.bottomRight : cornerEnum.bottomLeft
            color: visualContainer.color
            size: visualContainer.rounding

            anchors {
                left: visualContainer.rightMode ? undefined : visualContainer.right
                right: visualContainer.rightMode ? visualContainer.left : undefined
                bottom: visualContainer.bottom
                bottomMargin: Mem.options.bar.behavior.position === "bottom" ? 0 : Sizes.frameThickness
            }
        }

        RoundCorner {
            visible: c1.visible
            corner: visualContainer.rightMode ? cornerEnum.topRight : cornerEnum.topLeft
            color: visualContainer.color
            size: c1.size

            anchors {
                top: visualContainer.top
                left: visualContainer.rightMode ? undefined : visualContainer.right
                right: visualContainer.rightMode ? visualContainer.left : undefined
                topMargin: Mem.options.bar.behavior.position === "top" ? 0 : Sizes.frameThickness
            }
        }
    }

    HyprlandFocusGrab {
        windows: [root]
        active: GlobalStates.main.sidebar.show && !barMode
        onCleared: if (!pinned)
            hideSidebar()
    }

    mask: Region {
        item: interactiveContainer
    }

    Connections {
        target: sidebarContent

        function onHideBarRequested() {
            GlobalStates.main.sidebar.show = false;
            hideSidebar();
        }

        function onAppLaunched() {
            if (barMode) {
                reveal = false;
                reveal = Qt.binding(() => (hoverArea.containsMouse && barMode) || _isTransitioning || (seekOnSuper ? GlobalStates.superHeld : null) || PolkitService.flow !== null);
            } else {
                hideSidebar();
            }
        }

        function onDismiss() {
            hideSidebar();
        }

        function onContentToggleRequested() {
            barMode ? showSidebar() : hideSidebar();
        }
    }

    IpcHandler {
        target: "sidebar"

        function reveal_aux(cat: string) {
            sidebarContent.auxReveal(cat);
        }

        function reveal(cat: string) {
            sidebarContent.requestCategoryChange(cat);
        }

        function pin() {
            togglePin();
        }

        function hide() {
            hideSidebar();
        }
    }
}
