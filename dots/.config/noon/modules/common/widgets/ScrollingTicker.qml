// ScrollingTicker.qml
import QtQuick
import QtQuick.Controls
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    property string tickerText: "Sample Text"
    property alias tickerFont: textItem.font
    property alias tickerColor: textItem.color
    property real scrollSpeed: 15  // lower = faster
    property bool oppositeDirection: false  // false = left to right, true = right to left

    // Determine if text needs to scroll
    readonly property bool needsScrolling: textItem.implicitWidth > root.width

    clip: true  // Important: clip the overflowing text

    StyledText {
        id: textItem
        text: root.tickerText
        font.pixelSize: 48
        color: Colors.colOnLayer0
        anchors.verticalCenter: parent.verticalCenter
        font.weight: 400
        // Position logic: center if fits, animate if doesn't
        x: {
            if (!root.needsScrolling) {
                // Center the text if it fits
                return (root.width - textItem.implicitWidth) / 2;
            } else {
                // Use animated position if scrolling is needed
                return root.oppositeDirection ? -textItem.implicitWidth : root.width;
            }
        }

        Anim on x {
            id: scrollAnimation
            from: root.oppositeDirection ? -textItem.implicitWidth : root.width
            to: root.oppositeDirection ? root.width : -textItem.implicitWidth
            // duration: root.scrollSpeed

            duration: (textItem.implicitWidth + root.width) * root.scrollSpeed
            loops: Animation.Infinite
            running: root.visible && root.width > 0 && textItem.implicitWidth > 0 && root.needsScrolling
        }
    }
}
