import QtQuick
import QtQuick.Controls
import qs.common
import qs.common.functions

SpinBox {
    id: root

    property real baseHeight: 35
    property real radius: Rounding.normal
    property real innerButtonRadius: Rounding.tiny
    property color backgroundColor: Colors.colLayer2
    property color textColor: Colors.colOnLayer2
    property color buttonColor: ColorUtils.transparentize(Colors.colLayer2)
    property color buttonHoverColor: Colors.colLayer2Hover
    property color buttonActiveColor: Colors.colLayer2Active

    editable: true

    background: Rectangle {
        color: root.backgroundColor
        radius: root.radius
    }

    contentItem: Item {
        implicitHeight: root.baseHeight
        implicitWidth: 18

        StyledTextInput {
            id: labelText

            anchors.centerIn: parent
            text: root.displayText
            color: root.textColor
            font.pixelSize: Fonts.sizes.small
            validator: root.validator
            onTextChanged: root.value = parseFloat(text) || 0
            Keys.onReturnPressed: root.value = parseFloat(text) || 0
            Keys.onEnterPressed: root.value = parseFloat(text) || 0
        }
    }

    down.indicator: Rectangle {
        implicitHeight: root.baseHeight
        implicitWidth: root.baseHeight
        topLeftRadius: root.radius
        bottomLeftRadius: root.radius
        topRightRadius: root.innerButtonRadius
        bottomRightRadius: root.innerButtonRadius
        color: root.down.pressed ? root.buttonActiveColor : root.down.hovered ? root.buttonHoverColor : root.buttonColor

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
        }

        Symbol {
            anchors.centerIn: parent
            text: "remove"
            font.pixelSize: 20
            color: root.textColor
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.value -= root.stepSize
        }

        Behavior on color {
            CAnim {}
        }
    }

    up.indicator: Rectangle {
        implicitHeight: root.baseHeight
        implicitWidth: root.baseHeight
        topRightRadius: root.radius
        bottomRightRadius: root.radius
        topLeftRadius: root.innerButtonRadius
        bottomLeftRadius: root.innerButtonRadius
        color: root.up.pressed ? root.buttonActiveColor : root.up.hovered ? root.buttonHoverColor : root.buttonColor

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
        }

        Symbol {
            anchors.centerIn: parent
            text: "add"
            font.pixelSize: 20
            color: root.textColor
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.value += root.stepSize
        }

        Behavior on color {
            CAnim {}
        }
    }
}
