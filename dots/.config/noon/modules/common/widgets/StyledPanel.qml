import Quickshell
import Quickshell.Wayland
import qs.modules.common

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
