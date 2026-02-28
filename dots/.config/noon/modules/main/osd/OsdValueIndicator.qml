import QtQuick
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

StyledLoader {
    id: root
    asynchronous: true
    source: sanitizeSource("variants/", currentVariant)
    property bool volumeMode: false
    required property real value
    required property string icon
    readonly property string currentVariant: Mem.options.desktop.osd.mode
    required property var targetScreen

    signal valueModified(real newValue)
    signal interactionStarted
    signal interactionEnded

    onLoaded: {
        _item.value = Qt.binding(() => root.value);
        _item.icon = Qt.binding(() => root.icon);
        _item.targetScreen = Qt.binding(() => root.targetScreen);
        _item.valueModified.connect(root.valueModified);
        _item.interactionStarted.connect(root.interactionStarted);
        _item.interactionEnded.connect(root.interactionEnded);
        if ("volumeMode" in item)
            _item.volumeMode = Qt.binding(() => root.volumeMode);
    }
}
