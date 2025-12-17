import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.services
import qs.modules.common
import qs.modules.common.widgets

GroupButton {
    id: root
    horizontalPadding: 12
    verticalPadding: 8
    bounce: false
    property bool leftmost: false
    property bool rightmost: false
    leftRadius: (toggled || leftmost) ? (height / 2) : Rounding.verysmall
    rightRadius: (toggled || rightmost) ? (height / 2) : Rounding.verysmall
    colBackground: Colors.colSecondaryContainer
    contentItem: StyledText {
        color: parent.toggled ? Colors.colOnPrimary : Colors.colOnSecondaryContainer
        text: root.buttonText
    }
}
