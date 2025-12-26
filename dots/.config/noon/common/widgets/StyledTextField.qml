import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.common
import qs.common.widgets

TextField {
    id: folderPathField

    property alias colBackground: rect.color
    property alias radius: rect.radius

    placeholderTextColor: color
    color: Colors.colOnLayer1
    Keys.onEscapePressed: focus = false

    background: StyledRect {
        id: rect

        enableShadows: true
        color: Colors.colLayer2
        radius: Rounding.normal
    }

}
