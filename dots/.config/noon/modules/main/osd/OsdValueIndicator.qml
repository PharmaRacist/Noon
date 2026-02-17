import QtQuick
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

StyledLoader {
    id: root
    asynchronous: true
    source: sanitizeSource("variants/", currentVariant)
    required property real value
    required property string icon
    readonly property string currentVariant: Mem.options.desktop.osd.mode
    required property var targetScreen

    signal valueModified(real newValue)
    signal interactionStarted
    signal interactionEnded
    property real loaderValue: root.value
    property string loaderIcon: root.icon
    property var loaderTargetScreen: root.targetScreen
    property bool volumeMode: false
    onLoaded: {
        item.value = Qt.binding(() => root.loaderValue);
        item.icon = Qt.binding(() => root.loaderIcon);
        item.targetScreen = Qt.binding(() => root.loaderTargetScreen);
        item.valueModified.connect(root.valueModified);
        item.interactionStarted.connect(root.interactionStarted);
        item.interactionEnded.connect(root.interactionEnded);
        if ("volumeMode" in item)
            item.volumeMode = Qt.binding(() => root.volumeMode);
    }
}
