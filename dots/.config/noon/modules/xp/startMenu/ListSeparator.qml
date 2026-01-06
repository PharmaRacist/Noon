import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects
import qs.common
import qs.common.widgets
StyledRect {
    implicitHeight: 3
    color: "transparent"
    Layout.fillWidth: true
    property color accent: "#DDDDDD"
    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop {
            position: 0
            color: "transparent"
        }
        GradientStop {
            position: 0.5
            color: accent
        }
        GradientStop {
            position: 1
            color: "transparent"
        }
    }
}
