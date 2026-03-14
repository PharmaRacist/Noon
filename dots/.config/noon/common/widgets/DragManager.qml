import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common
import qs.services

/**
 * A convenience MouseArea for handling drag events.
 */
MouseArea {
    id: root

    property bool interactive: true
    property bool automaticallyReset: true
    readonly property real dragDiffX: _dragDiffX
    readonly property real dragDiffY: _dragDiffY
    property real startX: 0
    property real startY: 0
    property bool dragging: false
    property real _dragDiffX: 0
    property real _dragDiffY: 0

    signal dragPressed(real diffX, real diffY)
    signal dragReleased(real diffX, real diffY)

    function resetDrag() {
        _dragDiffX = 0;
        _dragDiffY = 0;
    }

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    onPressed: (mouse) => {
        if (!root.interactive) {
            if (mouse.button === Qt.LeftButton)
                mouse.accepted = false;

            return ;
        }
        if (mouse.button === Qt.LeftButton) {
            startX = mouse.x;
            startY = mouse.y;
        }
    }
    onReleased: (mouse) => {
        if (!root.interactive)
            return ;

        dragging = false;
        root.dragReleased(_dragDiffX, _dragDiffY);
        if (root.automaticallyReset)
            root.resetDrag();

    }
    onPositionChanged: (mouse) => {
        if (!root.interactive)
            return ;

        if (mouse.buttons & Qt.LeftButton) {
            root._dragDiffX = mouse.x - startX;
            root._dragDiffY = mouse.y - startY;
            const dist = Math.sqrt(root._dragDiffX * root._dragDiffX + root._dragDiffY * root._dragDiffY);
            root.dragPressed(_dragDiffX, _dragDiffY);
            root.dragging = true;
        }
    }
    onCanceled: (mouse) => {
        if (!root.interactive)
            return ;

        released(mouse);
    }
}
