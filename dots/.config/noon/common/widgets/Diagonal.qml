import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.common
import qs.common.widgets

Canvas {
    property int containerWidth: 200
    property int containerHeight: 100
    property color bgColor: "white"
    property bool flip: false
    property bool hide: false

    height: containerHeight
    width: containerWidth
    // Request repaint when properties change
    onBgColorChanged: requestPaint()
    onHideChanged: requestPaint()
    onFlipChanged: requestPaint()
    onPaint: {
        var ctx = getContext("2d");
        // Clear the canvas first
        ctx.clearRect(0, 0, width, height);
        // Set fill style and draw the shape
        ctx.fillStyle = hide ? "transparent" : bgColor;
        ctx.beginPath();
        if (flip) {
            // Flipped horizontally - angled cut on the right
            ctx.moveTo(0, 0);
            ctx.lineTo(width - 30, 0);
            ctx.lineTo(width, height);
            ctx.lineTo(30, height);
        } else {
            // Normal - angled cut on the left
            ctx.moveTo(30, 0);
            ctx.lineTo(width, 0);
            ctx.lineTo(width - 30, height);
            ctx.lineTo(0, height);
        }
        ctx.closePath();
        ctx.fill();
    }
}
