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

    property bool hoverMode: true
    property bool pinned: false
    property bool expanded: false
    property bool reveal: revealCondition
    property bool rightMode: barPosition === "left" || barPosition === "bottom"
    readonly property bool show: !hoverMode
    readonly property bool revealCondition: (hoverArea.containsMouse && hoverMode) || PolkitService.flow !== null
    readonly property int rounding: Rounding.verylarge
    readonly property int appearanceMode: Mem.options.sidebar.appearance.mode
    readonly property string barPosition: Mem.options.bar.behavior.position
    property alias selectedCategory: sidebarContent.selectedCategory
    readonly property int sidebarWidth: auxWidth + SidebarData.currentSize(hoverMode, root.expanded, selectedCategory)
    readonly property int auxWidth: sidebarContent.auxVisible && !hoverMode ? SidebarData.currentSize(false, false, sidebarContent.auxCategory) : 0

    function hide() {
        if (pinned)
            return;

        reveal = false;
        hoverMode = true;
        sidebarContent.selectedCategory = "";
        if (!pinned)
            reset_reveal_conditions();
    }

    function reveal_content() {
        hoverMode = false;
        sidebarContent.forceActiveFocus();
    }

    function close_aux() {
        sidebarContent.closeAux();
    }

    function reset_reveal_conditions() {
        root.reveal = Qt.binding(() => {
            return root.revealCondition;
        });
    }

    name: "sidebar"
    visible: true
    implicitWidth: visualContainer.width + rounding + bubble.width + Sizes.hyprland.gapsOut
    exclusiveZone: !hoverMode && pinned ? implicitWidth - rounding : -1
    aboveWindows: true
    kbFocus: show
    WlrLayershell.layer: WlrLayer.Overlay

    anchors {
        left: !root.rightMode || !pinned
        top: true
        right: root.rightMode || !pinned
        bottom: true
    }

    margins {
        top: !pinned && Mem.options.desktop.shell.mode === "nobuntu" ? 40 : 0
    }

    ScreenActionHint {
        z: -1
        icon: "keyboard_double_arrow_right"
        text: "Drop it Inside Your Shelf !"
        target: dropArea
    }

    Item {
        id: wrapperItem

        opacity: width > Sizes.hyprland.gapsOut + Sizes.hyprland.gapsIn ? 1 : 0
        width: {
            if (!hoverMode)
                return visualContainer.width + (bubble.visible ? bubble.width + Padding.verylarge * 2 : 0);

            return reveal ? Math.max(visualContainer.width, hoverArea.width) : Sizes.hyprland.gapsOut + Sizes.hyprland.gapsIn;
        }

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: !root.rightMode ? parent.left : undefined
            right: root.rightMode ? parent.right : undefined
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
                id: dropArea
                anchors.fill: parent
                keys: ["text/uri-list"]
                onEntered: NoonUtils.callIpc("sidebar reveal Shelf")
            }
        }
        StyledRectangularShadow {
            target: visualContainer
        }

        StyledRect {
            id: visualContainer

            width: root.sidebarWidth
            color: sidebarContent.colors.colLayer0
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

                panelWindow: root
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

        Behavior on width {
            Anim {}
        }
    }

    FocusHandler {
        windows: [root]
        active: show
        onCleared: {
            if (!pinned)
                hide();
        }
    }

    Binding {
        target: GlobalStates.main
        property: "sidebar"
        value: root
    }

    IpcHandler {
        target: "sidebar"
        function reveal_aux(cat: string) {
            sidebarContent.toggleAux(cat);
        }

        function reveal(cat: string) {
            sidebarContent.changeContent(cat);
        }

        function toggle_pin() {
            root.pinned = !root.pinned;
        }

        function hide() {
            root.hide();
        }
    }

    mask: Region {
        item: wrapperItem
    }
}
