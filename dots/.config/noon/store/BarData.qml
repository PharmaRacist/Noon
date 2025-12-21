import QtQuick
import Quickshell
import qs.modules.common
import qs.modules.common.functions
import qs.services
pragma Singleton

Singleton {
    readonly property var horizontalLayouts: ["Dynamic", "Minimal", "HyDe", "NovelKnocks", "Gnome-ish", "Sleek", "WindowsOnRoids"]
    readonly property var verticalLayouts: ["Dynamic"]
    readonly property real barPadding: 0.65
    readonly property string position: Mem.options.bar.behavior.position
    readonly property bool verticalBar: position === "left" || position === "right"
    readonly property int horizontalLayout: Mem.options.bar.currentLayout
    readonly property int verticalLayout: Mem.options.bar.currentVerticalLayout
    readonly property var barData: verticalBar ? getVerticalBar(verticalLayout) : getHorizontalBar(horizontalLayout)
    readonly property int currentBarExclusiveSize: getEffectiveExclusiveZone(barData) * 0.9
    readonly property int currentBarSize: verticalBar ? barData.width : barData.height
    // Position control properties
    readonly property int gaps: Sizes.hyprlandGapsOut
    readonly property int defaultHeight: Mem.options.bar.appearance.height
    readonly property int defaultWidth: Mem.options.bar.appearance.width
    readonly property int corners: Mem.options.bar.appearance.mode === 2 ? Rounding.verylarge : 0
    readonly property int elevationValue: Mem.options.bar.appearance.mode === 0 ? Sizes.barElevation : 0
    property var bars: [{
        "name": "Dynamic",
        "height": defaultHeight,
        "width": 0,
        "vertical": false,
        "layoutIndex": 0
    }, {
        "name": "Minimal",
        "height": 60,
        "width": 0,
        "vertical": false,
        "layoutIndex": 1
    }, {
        "name": "HyDe",
        "height": defaultHeight,
        "width": 0,
        "vertical": false,
        "layoutIndex": 2
    }, {
        "name": "NovelKnocks",
        "height": defaultHeight + 2 * elevationValue,
        "width": 0,
        "vertical": false,
        "layoutIndex": 3
    }, {
        "name": "Gnome-ish",
        "height": defaultHeight,
        "width": 0,
        "vertical": false,
        "layoutIndex": 4
    }, {
        "name": "Sleek",
        "height": 30,
        "width": 0,
        "vertical": false,
        "layoutIndex": 5
    }, {
        "name": "WindowsOnRoids",
        "height": 45,
        "width": 0,
        "vertical": false,
        "layoutIndex": 6
    }, {
        "name": "Dynamic",
        "height": 0,
        "width": defaultWidth,
        "vertical": true,
        "layoutIndex": 0
    }]

    function getByName(name) {
        return bars.find((bar) => {
            return bar.name === name;
        });
    }

    function getHorizontalBar(index) {
        return bars.find((bar) => {
            return !bar.vertical && bar.layoutIndex === index;
        }) || bars[0];
    }

    function getVerticalBar(index) {
        return bars.find((bar) => {
            return bar.vertical && bar.layoutIndex === index;
        }) || bars[0];
    }

    function getAllHorizontalBars() {
        return bars.filter((bar) => {
            return !bar.vertical;
        });
    }

    function getAllVerticalBars() {
        return bars.filter((bar) => {
            return bar.vertical;
        });
    }

    function getVisibleBars() {
        return bars.filter((bar) => {
            return bar.visible;
        });
    }

    function getEffectiveAnchors(bar) {
        if (bar.vertical)
            return {
            "left": position === "left",
            "top": true,
            "right": position === "right",
            "bottom": true
        };
        else
            return {
            "left": true,
            "top": position === "top",
            "right": true,
            "bottom": position === "bottom"
        };
    }

    function getEffectiveHeight(bar) {
        if (bar.vertical)
            return bar.height;
        else
            return bar.height + elevationValue + corners;
    }

    function getEffectiveWidth(bar) {
        if (!bar.vertical)
            return Screen.width;
        else
            return bar.width + elevationValue + corners;
    }

    function getEffectiveExclusiveZone(bar) {
        return bar.vertical ? bar.width : bar.height;
    }

    function getLayoutName(vertical, index) {
        if (vertical)
            return verticalLayouts[index];
        else
            return horizontalLayouts[index];
    }

    function getNextMode() {
        switch (Mem.options.bar.behavior.position) {
        case "top":
            return "left";
        case "bottom":
            return "right";
        case "right":
            return "bottom";
        case "left":
            return "top";
        default:
            return "left";
        }
    }

    function swapPosition() {
        if (verticalBar)
            Mem.options.bar.behavior.position = Mem.options.bar.behavior.position === "left" ? "right" : "left";
        else
            Mem.options.bar.behavior.position = Mem.options.bar.behavior.position === "top" ? "bottom" : "top";
    }

}
