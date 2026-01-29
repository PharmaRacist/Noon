import QtQuick
import QtQuick.Controls
import Quickshell
import qs.common
import qs.services

Loader {
    id: root
    asynchronous: true
    readonly property var variants: ({
            "center_island": "CenterIsland.qml",
            "bottom_pill": "BottomPill.qml",
            "side_bay": "SideBay.qml",
            "windows_10": "Windows_10.qml",
            "nobuntu": "Nobuntu.qml"
        })
    source: "variants/" + variants[currentVariant] || "variants/CenterIsland.qml"

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
        if (currentVariant === "side_bay")
            item.volumeMode = Qt.binding(() => root.volumeMode);
    }
}
