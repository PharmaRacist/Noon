import QtQuick
import QtQuick.Controls
import Quickshell
import qs.common
import qs.services

Loader {
    id: root
    asynchronous: true
    source: Mem.options.desktop.osd.mode === "center_island" ? "variants/CenterIsland.qml" : "variants/BottomPill.qml"

    required property real value
    required property string icon
    required property var targetScreen

    signal valueModified(real newValue)
    signal interactionStarted
    signal interactionEnded
    property real loaderValue: root.value
    property string loaderIcon: root.icon
    property var loaderTargetScreen: root.targetScreen

    onLoaded: {
        item.value = Qt.binding(() => root.loaderValue);
        item.icon = Qt.binding(() => root.loaderIcon);
        item.targetScreen = Qt.binding(() => root.loaderTargetScreen);

        item.valueModified.connect(root.valueModified);
        item.interactionStarted.connect(root.interactionStarted);
        item.interactionEnded.connect(root.interactionEnded);
    }
}
