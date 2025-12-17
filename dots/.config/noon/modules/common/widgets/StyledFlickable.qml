import QtQuick
import QtQuick.Controls
import qs.modules.common

Flickable {
    id: root

    property real touchpadScrollFactor: Mem.options.interactions.scrolling.touchpadScrollFactor ?? 100
    property real mouseScrollFactor: Mem.options.interactions.scrolling.mouseScrollFactor ?? 50
    property real mouseScrollDeltaThreshold: Mem.options.interactions.scrolling.mouseScrollDeltaThreshold ?? 120
    // Accumulated scroll destination so wheel deltas stack while animating
    property real scrollTargetY: 0

    maximumFlickVelocity: 1000
    boundsBehavior: Flickable.StopAtBounds
    // Keep target synced when not animating (e.g., drag/flick or programmatic changes)
    onContentYChanged: {
        if (!scrollAnim.running)
            root.scrollTargetY = root.contentY;
    }

    MouseArea {
        visible: Mem.options.interactions.scrolling.fasterTouchpadScroll
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: function (wheelEvent) {
            const delta = wheelEvent.angleDelta.y / root.mouseScrollDeltaThreshold;
            // The angleDelta.y of a touchpad is usually small and continuous,
            // while that of a mouse wheel is typically in multiples of ±120.
            var scrollFactor = Math.abs(wheelEvent.angleDelta.y) >= root.mouseScrollDeltaThreshold ? root.mouseScrollFactor : root.touchpadScrollFactor;
            const maxY = Math.max(0, root.contentHeight - root.height);
            const base = scrollAnim.running ? root.scrollTargetY : root.contentY;
            var targetY = Math.max(0, Math.min(base - delta * scrollFactor * 0.08, maxY));
            root.scrollTargetY = targetY;
            root.contentY = targetY;
            wheelEvent.accepted = true;
        }
    }

    ScrollBar.vertical: StyledScrollBar {}

    Behavior on contentY {
        Anim {
            id: scrollAnim
            duration: Animations.durations.small
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Animations.curves.expressiveFastSpatial
        }
    }
}
