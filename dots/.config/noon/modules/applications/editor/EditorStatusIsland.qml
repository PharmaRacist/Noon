import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common
import qs.common.widgets

Item {
    id: statusBar
    anchors {
        bottom: parent.bottom
        right: parent.right
        margins: Padding.massive
    }
    width: Sizes.editor.statusIsland.width
    height: Sizes.editor.statusIsland.height
    StyledRectangularShadow {
        target: bg
    }
    StyledRect {
        id: bg
        anchors.fill: parent
        color: Colors.colLayer2
        clip: true
        enableBorders: true
        radius: Rounding.verylarge
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            StyledToolTip {
                extraVisibleCondition: parent.containsMouse
                content: "Ctrl+S: Save | Ctrl+F: Format JSON"
            }
        }
        StyledRect {
            id: sideRect
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            implicitWidth: height
            color: Colors.colSecondaryContainer
            Symbol {
                animateChange: true
                anchors.horizontalCenterOffset: 2
                anchors.centerIn: parent
                font.pixelSize: 20
                fill: 1
                text: root.modified ? "stylus" : "save"
            }
        }
        StyledText {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: sideRect.right
                leftMargin: Padding.normal
                right: parent.right
            }
            color: Colors.colOnLayer3
            font.weight: Font.DemiBold
            font.family: Fonts.family.monospace
            font.pixelSize: Fonts.sizes.normal
            text: (textEdit.cursorPosition - textEdit.text.lastIndexOf('\n', textEdit.cursorPosition - 1) - 1) + " / " + textEdit.text.substring(0, textEdit.cursorPosition).split('\n').length
        }
    }
}
