import Quickshell
import Quickshell.Wayland
import qs.common
import qs.common.utils

PanelWindow {
    id: root

    required property string name
    property bool kbFocus: false

    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.namespace: `noon:${name}`
    WlrLayershell.keyboardFocus: (root.kbFocus === true) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    aboveWindows: true
}
