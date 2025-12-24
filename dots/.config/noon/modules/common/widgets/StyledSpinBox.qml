import QtQuick
import QtQuick.Controls
import qs.modules.common

/**
 * Material 3 styled SpinBox component with debouncing support.
 */
SpinBox {
    id: root

    property real baseHeight: 35
    property real radius: Rounding.normal
    property real innerButtonRadius: Rounding.tiny
    // Debouncing properties
    property bool enableDebouncing: true
    property int debounceDelay: 300 // milliseconds
    // Color properties
    property color backgroundColor: Colors.colLayer2
    property color textColor: Colors.colOnLayer2
    property color buttonColor: ColorUtils.transparentize(Colors.colLayer2)
    property color buttonHoverColor: Colors.colLayer2Hover
    property color buttonActiveColor: Colors.colLayer2Active

    // Function to handle debounced value changes
    function updateValueDebounced(newValue) {
        if (root.enableDebouncing) {
            buttonDebounceTimer.pendingValue = newValue;
            buttonDebounceTimer.restart();
        } else {
            root.value = newValue;
        }
    }

    editable: true

    // Debounce timer for text input
    Timer {
        id: debounceTimer

        interval: root.debounceDelay
        repeat: false
        onTriggered: {
            root.value = parseFloat(labelText.text) || 0;
        }
    }

    // Debounce timer for button actions
    Timer {
        id: buttonDebounceTimer

        property real pendingValue: 0

        interval: root.debounceDelay
        repeat: false
        onTriggered: {
            root.value = pendingValue;
        }
    }

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
            onTextChanged: {
                if (root.enableDebouncing)
                    debounceTimer.restart();
                else
                    root.value = parseFloat(text) || 0;
            }
            Keys.onReturnPressed: {
                // Force immediate value update on Enter
                debounceTimer.stop();
                buttonDebounceTimer.stop();
                root.value = parseFloat(text) || 0;
            }
            Keys.onEnterPressed: {
                // Handle Enter key on numeric keypad
                debounceTimer.stop();
                buttonDebounceTimer.stop();
                root.value = parseFloat(text) || 0;
            }
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

        MaterialSymbol {
            anchors.centerIn: parent
            text: "remove"
            font.pixelSize: 20
            color: root.textColor
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.updateValueDebounced(root.value - root.stepSize);
            }
        }

        Behavior on color {
            CAnim {
            }

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

        MaterialSymbol {
            anchors.centerIn: parent
            text: "add"
            font.pixelSize: 20
            color: root.textColor
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.updateValueDebounced(root.value + root.stepSize);
            }
        }

        Behavior on color {
            CAnim {
            }

        }

    }

}
