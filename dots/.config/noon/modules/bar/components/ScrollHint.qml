import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common
import qs.common.widgets

// Scroll hint
Revealer {
    id: root

    property string icon
    property string side: "left"
    property string tooltipText: ""

    MouseArea {
        property bool hovered: false

        anchors.right: root.side === "left" ? parent.right : undefined
        anchors.left: root.side === "right" ? parent.left : undefined
        implicitWidth: contentColumnLayout.implicitWidth
        implicitHeight: contentColumnLayout.implicitHeight
        hoverEnabled: true
        onEntered: hovered = true
        onExited: hovered = false
        acceptedButtons: Qt.NoButton

        StyledToolTip {
            extraVisibleCondition: tooltipText.length > 0
            content: tooltipText
        }

        ColumnLayout {
            id: contentColumnLayout

            anchors.centerIn: parent
            spacing: -5

            MaterialSymbol {
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                text: "keyboard_arrow_up"
                font.pixelSize: 14
                color: Colors.colSubtext ?? "black"
            }

            MaterialSymbol {
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                text: root.icon
                font.pixelSize: 14
                color: Colors.colSubtext ?? "black"
            }

            MaterialSymbol {
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                text: "keyboard_arrow_down"
                font.pixelSize: 14
                color: Colors.colSubtext ?? "black"
            }

        }

    }

}
