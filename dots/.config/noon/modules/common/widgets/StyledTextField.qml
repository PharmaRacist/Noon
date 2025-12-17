import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.modules.common
import qs.modules.common.widgets
import QtQuick.Controls

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
