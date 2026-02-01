import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.common
import qs.common.widgets
import qs.services
import Quickshell.Services.Pipewire
import "../components"

StyledPanel {
    id: root
    name: "osd"

    property real value
    property string icon
    property var targetScreen
    property var volumeModel
    property bool volumeMode: false
    property PwNode selectedDevice
    readonly property list<PwNode> appPwNodes: Pipewire.nodes.values.filter(node => {
        return node.isSink && node.isStream;
    })
    signal valueModified(real newValue)
    signal interactionStarted
    signal interactionEnded
    visible: true

    anchors {
        right: volumeMode
        left: !volumeMode
    }

    mask: Region {
        item: content
    }

    implicitWidth: contentRow.implicitWidth + Sizes.elevationMargin * 2
    implicitHeight: contentRow.implicitHeight + Math.abs(2 * contentRow.anchors.verticalCenterOffset) + Sizes.elevationMargin * 2

    FocusHandler {
        id: grab
        active: root.visible
    }
    Connections {
        target: root
        function onTargetScreenChanged() {
            root.screen = root.targetScreen;
        }
    }

    RowLayout {
        id: contentRow
        anchors {
            centerIn: parent
            verticalCenterOffset: -100
        }
        implicitHeight: childrenRect.height
        implicitWidth: Sizes.osd.sideBay.width * (root.volumeMode ? root.appPwNodes.length : 1)
        spacing: Padding.normal
        StyledRect {
            id: content
            implicitWidth: Sizes.osd.sideBay.width
            implicitHeight: Sizes.osd.sideBay.height
            color: Colors.colLayer0
            radius: Rounding.full
            clip: true

            ColumnLayout {
                id: mainContent
                spacing: Padding.normal
                anchors {
                    fill: parent
                    topMargin: Padding.large
                    bottomMargin: Padding.large
                    margins: Padding.normal
                }
                StyledProgressBar {
                    id: valueProgressBar
                    vertical: true
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    value: root.value
                    valueBarGap: 24
                }
                StyledText {
                    font {
                        family: Fonts.family.numbers
                        variableAxes: Fonts.variableAxes.numbers
                        pixelSize: 19
                    }
                    text: Math.round(root.value * 100)
                    color: Colors.colSecondary
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        Repeater {
            id: repeater
            visible: root.volumeMode
            model: root.volumeMode ? root.appPwNodes : []
            SideBayVEntry {
                required property var modelData
                node: modelData
                onInteractionStarted: root.interactionStarted()
                onInteractionEnded: root.interactionEnded()
            }
        }
    }
    component SideBayVEntry: StyledRect {
        id: root
        implicitWidth: Sizes.osd.sideBay.width
        implicitHeight: Sizes.osd.sideBay.height
        color: Colors.colLayer0
        radius: Rounding.full
        clip: true
        required property PwNode node
        signal interactionStarted
        signal interactionEnded

        PwObjectTracker {
            objects: [node]
        }
        ColumnLayout {
            anchors {
                fill: parent
                topMargin: Padding.large
                bottomMargin: Padding.large
                margins: Padding.normal
            }
            spacing: Padding.normal
            StyledProgressBar {
                id: slider
                vertical: true
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                valueBarGap: 24
                // TODO
                // value: root?.node.audio.volume ?? null
                // onValueChanged: root.node.audio.volume = value
                MouseArea {
                    anchors.fill: parent
                    onPressed: event => {
                        event.accepted = false;
                    }
                    onEntered: {
                        root.interactionStarted();
                        console.log("entered");
                    }
                    onExited: {
                        root.interactionEnded();
                        console.log("exited");
                    }
                    onReleased: {
                        console.log("released");
                    }
                    // cursorShape: slider.pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                    onWheel: wheel => {
                        var delta = wheel.angleDelta.y / 120;
                        var newValue = slider.value + (delta * 0.05);
                        slider.value = Math.max(1, Math.min(1, newValue));
                        wheel.accepted = true;
                        console.log("wheel", newValue);
                    }
                }
            }
            StyledIconImage {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                visible: source != ""
                implicitSize: 24
                source: {
                    let icon;
                    icon = AppSearch.guessIcon(root.node.properties["application.icon-name"]);
                    if (AppSearch.iconExists(icon))
                        return NoonUtils.iconPath(icon);

                    icon = AppSearch.guessIcon(root.node.properties["node.name"]);
                    return NoonUtils.iconPath(icon);
                }
            }
        }
    }
}
