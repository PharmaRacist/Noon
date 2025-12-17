import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets

MouseArea {
    id: root
    property var topAction
    property var downAction
    property bool showCondition

    anchors.fill: parent
    propagateComposedEvents: true
    scrollGestureEnabled: true
    onWheel: function (wheel) {
        let scrollSum = 0;
        let toggleThreshold = 20;
        scrollSum += wheel.angleDelta.y;

        if (!root.showCondition && scrollSum <= -toggleThreshold) {
            root.downAction;
            scrollSum = 0;
        } else if (root.showCondition && scrollSum >= toggleThreshold) {
            root.topAction;
            scrollSum = 0;
        }

        wheel.accepted = true;
    }
}
