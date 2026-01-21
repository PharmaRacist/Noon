import "./layouts"
import "./verticalBar"
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.common
import qs.common.utils
import qs.common.widgets
import qs.services
import qs.store

Scope {
    id: bar

    property bool vertical: BarData.verticalBar
    readonly property var horizontalLayouts: BarData.horizontalLayouts
    readonly property var verticalLayouts: BarData.verticalLayouts
    property int horizontalLayout: Mem.options.bar.currentLayout
    property int verticalLayout: Mem.options.bar.currentVerticalLayout
    readonly property var currentBarData: vertical ? BarData.getVerticalBar(verticalLayout) : BarData.getHorizontalBar(horizontalLayout)
    readonly property var effectiveAnchors: BarData.getEffectiveAnchors(currentBarData)
    // Hover-to-reveal properties
    property bool exclusiveHover: !Mem.options.bar.appearance.useBg
    property bool hoverEnabled: Mem.options.bar.behavior.autoHide
    property int peekSize: 10
    property var horizontalLayoutComponents: {
        let components = {};
        for (let i = 0; i < horizontalLayouts.length; i++) {
            components[i] = Qt.createComponent(`./layouts/${horizontalLayouts[i]}.qml`);
        }
        return components;
    }
    property var verticalLayoutComponents: {
        let components = {};
        for (let i = 0; i < verticalLayouts.length; i++) {
            components[i] = Qt.createComponent(`./verticalBar/${verticalLayouts[i]}.qml`);
        }
        return components;
    }
    property var horizontalModel: []
    property var verticalModel: []
    property var modelProxy: []
    property string currentPosition: Mem.options.bar.behavior.position

    function updateModels() {
        let screensModel = Mem.options.bar.behavior.showOnAll ? Quickshell.screens : [Quickshell.screens[0]] ?? Quickshell.screens;
        if (vertical) {
            horizontalModel = [];
            verticalModel = screensModel;
        } else {
            verticalModel = [];
            horizontalModel = screensModel;
        }
    }

    function debounceRecreate() {
        modelProxy = [];
        updateModels();
        debounceTimer.restart();
    }
    Connections {
        target: Mem.options.bar

        function onCurrentLayoutChanged() {
            debounceTimer.restart();
        }
        function onCurrentVerticalLayoutChanged() {
            debounceTimer.restart();
        }
    }
    onVerticalChanged: updateModels()
    onCurrentPositionChanged: debounceRecreate()

    Timer {
        id: debounceTimer

        interval: 100
        onTriggered: modelProxy = vertical ? verticalModel : horizontalModel
    }

    Variants {
        model: modelProxy

        StyledPanel {
            id: barRoot

            property ShellScreen modelData
            property bool barHovered: false

            screen: modelData
            WlrLayershell.layer: WlrLayer.Top
            name: "bar"
            property int shadowsAccounted: 100
            implicitWidth: vertical ? BarData.getEffectiveWidth(currentBarData) + shadowsAccounted : Screen.width
            implicitHeight: !vertical ? BarData.getEffectiveHeight(currentBarData) + shadowsAccounted : Screen.height
            exclusiveZone: {
                if (!bar.hoverEnabled)
                    return BarData.getEffectiveExclusiveZone(currentBarData);

                return barRoot.barHovered && bar.exclusiveHover ? BarData.getEffectiveExclusiveZone(currentBarData) : bar.peekSize;
            }

            anchors {
                left: effectiveAnchors.left
                top: effectiveAnchors.top
                right: effectiveAnchors.right
                bottom: effectiveAnchors.bottom
            }

            // Hover detection area
            MouseArea {
                id: hoverArea

                anchors.fill: parent
                hoverEnabled: bar.hoverEnabled
                acceptedButtons: Qt.NoButton
                propagateComposedEvents: true
                onEntered: {
                    if (bar.hoverEnabled)
                        barRoot.barHovered = true;
                }
                onExited: {
                    if (bar.hoverEnabled)
                        barRoot.barHovered = false;
                }

                // Container for bar content with margins
                Item {
                    id: barContainer

                    // Calculate margins for hiding based on position
                    property int hideMargin: {
                        if (!bar.hoverEnabled || barRoot.barHovered)
                            return 0;

                        return -(vertical ? BarData.getEffectiveWidth(currentBarData) : BarData.getEffectiveHeight(currentBarData) - bar.peekSize);
                    }

                    opacity: !bar.hoverEnabled || barRoot.barHovered ? 1 : 0
                    implicitWidth: vertical ? BarData.getEffectiveWidth(currentBarData) : Screen.width
                    implicitHeight: !vertical ? BarData.getEffectiveHeight(currentBarData) : Screen.height
                    anchors {
                        top: vertical || bar.currentPosition === "top" ? parent.top : undefined
                        bottom: vertical || bar.currentPosition === "bottom" ? parent.bottom : undefined
                        left: vertical && bar.currentPosition !== "right" ? parent.left : undefined
                        right: vertical && bar.currentPosition !== "left" ? parent.right : undefined
                        leftMargin: (bar.currentPosition === "left") ? hideMargin : 0
                        rightMargin: (bar.currentPosition === "right") ? hideMargin : 0
                        topMargin: (bar.currentPosition === "top") ? hideMargin : 0
                        bottomMargin: (bar.currentPosition === "bottom") ? hideMargin : 0
                    }

                    // Unified layout loader
                    Loader {
                        id: layoutLoader
                        asynchronous: true
                        anchors.fill: parent
                        sourceComponent: vertical ? bar.verticalLayoutComponents[bar.verticalLayout] : bar.horizontalLayoutComponents[bar.horizontalLayout]
                        onLoaded: if (item)
                            item.barRoot = barRoot
                    }

                    // Smooth transitions for margins
                    Behavior on anchors.topMargin {
                        enabled: !vertical && bar.currentPosition === "top"

                        Anim {
                            duration: Animations.durations.normal
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Animations.curves.expressiveFastSpatial
                        }
                    }

                    Behavior on anchors.bottomMargin {
                        enabled: !vertical && bar.currentPosition === "bottom"

                        Anim {
                            duration: Animations.durations.normal
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Animations.curves.expressiveFastSpatial
                        }
                    }

                    Behavior on anchors.leftMargin {
                        enabled: vertical && bar.currentPosition === "left"

                        Anim {
                            duration: Animations.durations.normal
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Animations.curves.expressiveFastSpatial
                        }
                    }

                    Behavior on anchors.rightMargin {
                        enabled: vertical && bar.currentPosition === "right"

                        Anim {
                            duration: Animations.durations.normal
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Animations.curves.expressiveFastSpatial
                        }
                    }
                }
            }

            mask: Region {

                item: Rectangle {
                    property bool isHorizontal: !vertical

                    x: isHorizontal ? 0 : (bar.currentPosition === "right" ? (barRoot.width - barRoot.exclusiveZone) : 0)
                    y: isHorizontal ? (bar.currentPosition === "bottom" ? (barRoot.height - barRoot.exclusiveZone) : 0) : 0
                    width: isHorizontal ? barRoot.width : barRoot.exclusiveZone
                    height: isHorizontal ? barRoot.exclusiveZone : barRoot.height
                    visible: false
                }
            }
        }
    }
}
