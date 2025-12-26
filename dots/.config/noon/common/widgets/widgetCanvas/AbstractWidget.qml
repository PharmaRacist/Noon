import QtQuick
import Quickshell
import qs.common

/*
 * Widget to be placed on a WidgetCanvas
 */
MouseArea {
    id: root

    property alias animateXPos: xBehavior.enabled
    property alias animateYPos: yBehavior.enabled
    property bool draggable: true

    function center() {
        root.x = (root.parent.width - root.width) / 2;
        root.y = (root.parent.height - root.height) / 2;
    }

    drag.target: draggable ? root : undefined
    cursorShape: (draggable && containsPress) ? Qt.ClosedHandCursor : draggable ? Qt.OpenHandCursor : Qt.ArrowCursor

    Behavior on x {
        id: xBehavior

        Anim {
        }

    }

    Behavior on y {
        id: yBehavior

        Anim {
        }

    }

}
