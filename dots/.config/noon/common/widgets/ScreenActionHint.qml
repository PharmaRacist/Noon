import QtQuick
import QtQuick.Layouts

import qs.common
import qs.common.widgets

StyledRect {
    id: dropHint
    z: 999
    opacity: isActive ? 1 : 0
    anchors.fill: parent

    property string text: "You Can Drop it Now!"
    property string icon: "keyboard_double_arrow_down"
    required property var target
    readonly property bool isActive: target.containsDrag
    property real scale: 1
    CLayout {
        z: 9999
        anchors.centerIn: parent
        Symbol {
            id: symbol
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            color: Colors.colOnLayer0
            font.pixelSize: 120 * dropHint.scale
            text: dropHint.icon
            fill: 1
        }

        StyledText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Fonts.sizes.title * dropHint.scale
            font.variableAxes: Fonts.variableAxes.title
            color: Colors.colOnLayer0
            text: dropHint.text
        }
    }

    gradient: Gradient {
        GradientStop {
            position: 0
            color: "transparent"
        }
        GradientStop {
            position: 0.999
            color: Colors.colPrimaryContainer
        }
    }
}
