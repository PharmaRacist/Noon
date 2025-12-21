import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services

QuickToggleButton {
    id: kdeconnectd

    hasDialog: true
    onRequestDialog: GlobalStates.showKdeConnectDialog = true
    toggled: KdeConnectService.daemonRunning
    buttonIcon: KdeConnectService.availableDevices.length > 0 ? "phonelink" : "phonelink_off"
    onClicked: KdeConnectService.daemonRunning = !KdeConnectService.daemonRunning
}
