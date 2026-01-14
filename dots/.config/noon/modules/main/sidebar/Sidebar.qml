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

    property bool hoverMode: true
    property bool pinned: false
    property bool _transitioning: false
    property bool reveal: revealCondition // reveal -- show bar - hoverMode
    property alias expanded: sidebarContent.expanded

    readonly property bool show: !hoverMode // Show Content
    readonly property bool rightMode: barPosition === "left" || barPosition === "bottom"
    readonly property bool revealCondition: (hoverArea.containsMouse && hoverMode) || _transitioning || PolkitService.flow !== null
    readonly property int rounding: Rounding.verylarge
    readonly property int appearanceMode: Mem.options.sidebar.appearance.mode
    readonly property int sidebarWidth: SidebarData.currentSize(hoverMode, root.expanded, sidebarContent.selectedCategory) + auxWidth
    readonly property int auxWidth: sidebarContent.auxVisible && !hoverMode ? SidebarData.currentSize(false, false, sidebarContent.auxCategory) : 0
    readonly property string barPosition: Mem.options.bar.behavior.position

    implicitWidth: visualContainer.width + rounding + bubble.width + Sizes.hyprland.gapsOut
    exclusiveZone: !hoverMode && pinned ? implicitWidth - rounding : -1
    aboveWindows: true
    kbFocus: show
    WlrLayershell.layer: SidebarData?.isOverlay(sidebarContent.selectedCategory) ? WlrLayer.Overlay : WlrLayer.Top

    anchors {
        left: !root.rightMode || !pinned
        top: true
        right: root.rightMode || !pinned
        bottom: true
    }

    function hide() {
        if (_transitioning && pinned)
            return;

        _transitioning = true;
        reveal = true;
        finalizeHide();
    }

    function reveal_content() {
        if (_transitioning)
            return;

        hoverMode = false;
        sidebarContent.forceActiveFocus();
    }
    function finalizeHide() {
        _transitioning = false;
        hoverMode = true;

        if (!pinned)
            reset_reveal_conditions();
    }
    function reset_reveal_conditions() {
        root.reveal = Qt.binding(() => root.revealCondition);
    }

    Item {
        id: wrapperItem

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: !root.rightMode ? parent.left : undefined
            right: root.rightMode ? parent.right : undefined
        }

        width: {
            if (!hoverMode) {
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
            enabled: root.hoverMode
            z: 1000
            hoverEnabled: true
            acceptedButtons: Qt.NoButton

            width: root.reveal ? visualContainer.width : Sizes.hyprland.gapsOut + Sizes.hyprland.gapsIn
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: !root.rightMode ? parent.left : undefined
                right: root.rightMode ? parent.right : undefined
            }

            DropArea {
                anchors.fill: parent
                keys: ["text/uri-list"]
                onEntered: Noon.callIpc("sidebar reveal Shelf")
            }
        }

        StyledRectangularShadow {
            target: visualContainer
        }

        StyledRect {
            id: visualContainer

            width: root.sidebarWidth
            color: sidebarContent.contentColor

            // Calculate rounded corners based on screen position
            topRightRadius: !root.rightMode && root.appearanceMode === 1 ? root.rounding : 0
            bottomRightRadius: !root.rightMode && root.appearanceMode === 1 ? root.rounding : 0
            topLeftRadius: root.rightMode && root.appearanceMode === 1 ? root.rounding : 0
            bottomLeftRadius: root.rightMode && root.appearanceMode === 1 ? root.rounding : 0

            anchors {
                top: parent.top
                bottom: parent.bottom
                left: !rightMode ? parent.left : undefined
                right: rightMode ? parent.right : undefined
                leftMargin: !rightMode ? ((!hoverMode || reveal) ? -1 : -(width - 1)) : 0
                rightMargin: rightMode ? ((!hoverMode || reveal) ? -1 : -(width - 1)) : 0
                topMargin: root.appearanceMode === 1 && root.barPosition !== "top" ? Sizes.frameThickness : 0
                bottomMargin: root.appearanceMode === 1 && root.barPosition !== "bottom" ? Sizes.frameThickness : 0
            }

            Content {
                id: sidebarContent
                rightMode: root.rightMode
                panelWindow: root
                showContent: !hoverMode
                pinned: root.pinned
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
                Anim {
                    duration: Animations.durations.normal
                    easing.bezierCurve: Animations.curves.emphasized
                }
            }
        }

        SidebarBubble {
            id: bubble
            show: !hoverMode
            rightMode: root.rightMode
            selectedCategory: sidebarContent.selectedCategory
            colors: sidebarContent.colors
            anchors {
                right: !root.rightMode ? undefined : visualContainer.left
                left: root.rightMode ? undefined : visualContainer.right
                bottom: visualContainer.bottom
                margins: Padding.verylarge
            }
        }

        RoundCorner {
            id: c1
            visible: root.appearanceMode === 2
            corner: root.rightMode ? cornerEnum.bottomRight : cornerEnum.bottomLeft
            color: visualContainer.color
            size: root.rounding

            anchors {
                left: root.rightMode ? undefined : visualContainer.right
                right: root.rightMode ? visualContainer.left : undefined
                bottom: visualContainer.bottom
                bottomMargin: root.barPosition === "bottom" ? 0 : Sizes.frameThickness
            }
        }

        RoundCorner {
            visible: c1.visible
            corner: root.rightMode ? cornerEnum.topRight : cornerEnum.topLeft
            color: visualContainer.color
            size: c1.size

            anchors {
                top: visualContainer.top
                left: root.rightMode ? undefined : visualContainer.right
                right: root.rightMode ? visualContainer.left : undefined
                topMargin: root.barPosition === "top" ? 0 : Sizes.frameThickness
            }
        }
    }

    HyprlandFocusGrab {
        windows: [root]
        active: show
        onCleared: if (!pinned)
            hide()
    }

    mask: Region {
        item: wrapperItem
    }
    Binding {
        target: GlobalStates.main
        property: "sidebar"
        value: root
    }
    Connections {
        target: sidebarContent

        function onAppLaunched() {
            root.hide();
        }

        function onDismiss() {
            root.hide();
        }
        function onRequestPin() {
            root.pinned = !root.pinned;
        }
        function onContentToggleRequested() {
            hoverMode ? reveal_content() : hide();
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
        function toggle_pin() {
            root.pinned = !root.pinned;
        }
        function hide() {
            root.hide();
        }
    }
}
