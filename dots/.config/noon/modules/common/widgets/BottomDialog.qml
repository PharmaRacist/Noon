import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Item {
    id: root
    property int collapsedHeight: 200
    property int expandedHeight: 400
    property bool expand: false
    property bool reveal: show || bg.visible
    property bool show: false

    property var contentItem
    // visible: reveal
    anchors.fill: parent
    Rectangle {
        z: -1
        opacity: root.reveal ? 1 : 0
        color: ColorUtils.transparentize(Colors.m3.m3surfaceDim, 0.24)
        anchors.fill: parent
        MouseArea {
            z: -1
            hoverEnabled: true
            anchors.fill: parent
            onClicked: root.show = false
            propagateComposedEvents: true
            scrollGestureEnabled: true
            acceptedButtons: root.show ? Qt.LeftButton : Qt.NoButton

            property int scrollSum: 0
            property int toggleThreshold: 750

            onWheel: function (wheel) {
                scrollSum += wheel.angleDelta.y;
                if (scrollSum >= toggleThreshold) {
                    if (!root.show) {
                        root.show = true;
                        root.expand = false;
                    } else if (!root.expand) {
                        root.expand = true;
                    }
                    scrollSum = 0;
                } else if (scrollSum <= -toggleThreshold) {
                    if (root.expand) {
                        root.expand = false;
                    } else if (root.show) {
                        root.show = false;
                    }
                    scrollSum = 0;
                }
                wheel.accepted = true;
            }
        }
        Behavior on opacity {
            Anim {}
        }
    }
    StyledRect {
        id: bg
        z: 999
        visible: height > 0
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: root.show ? root.expand ? root.expandedHeight : root.collapsedHeight : 0
        topRadius: Rounding.verylarge
        color: Colors.colLayer2
        enableShadows: true

        Behavior on height {
            Anim {}
        }
        children: root.contentItem
        Component.onCompleted: {
            contentItem.anchors.fill = root;
        }
    }
}
