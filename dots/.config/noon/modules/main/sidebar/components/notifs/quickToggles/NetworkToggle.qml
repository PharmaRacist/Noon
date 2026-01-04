import qs.common
import qs.common.widgets
import qs.services

QuickToggleButton {
    property bool showWifiDialog: false

    hasDialog: true
    buttonName: !NetworkService.enabled ? "Offline" : NetworkService.networkName
    toggled: NetworkService.networkName.length > 0 && NetworkService.networkName !== "lo"
    buttonIcon: NetworkService.materialSymbol
    onRequestDialog: GlobalStates.showWifiDialog = true
    onClicked: NetworkService.toggleWifi()
}
