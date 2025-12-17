import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.modules.common
import qs.modules.common.widgets
import qs.services

StyledRect {
    id: root

    required property real value
    property string icon

    signal valueModified(real newValue)
    signal interactionStarted
    signal interactionEnded

    implicitWidth: Sizes.osdWidth
    implicitHeight: Sizes.osdHeight
    enableShadows: true
    color: Colors.colLayer0
    radius: Rounding.normal
    clip: true

    MouseArea {
        id: dragArea
        anchors.fill: parent
        hoverEnabled: true

        property bool dragging: false

        onPressed: {
            dragging = true
            root.interactionStarted()
        }

        onReleased: {
            dragging = false
            root.interactionEnded()
        }

        onPositionChanged: {
            if (!dragging)
                return

            var h = valueProgressBar.height
            var pos = Math.max(0, Math.min(h, mouseY))
            var newValue = 1 - (pos / h)
            root.value = newValue
            root.valueModified(newValue)
        }
    }

    Rectangle {
        id: sideRect
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        implicitWidth: 40
        color: Colors.colPrimary

        ColumnLayout {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset:2
            spacing: -2

            MaterialSymbol {
                fill: 1
                animateChange: true
                color: Colors.colOnPrimary
                text: root.icon
                font.pixelSize: Fonts.sizes.huge
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                color: Colors.colOnPrimary
                text: Math.round(root.value * 100)
                font.variableAxes: Fonts.variableAxes.numbers
                font.pixelSize: Fonts.sizes.small
            }
        }
    }

    RowLayout {
        id: mainContent
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: sideRect.right
            right: parent.right
            rightMargin: Padding.large
            leftMargin: Padding.large
        }

        spacing: Padding.normal

        StyledProgressBar {
            id: valueProgressBar
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 2
            value: root.value
            valueBarGap: parent.height / 3
        }
    }
}
