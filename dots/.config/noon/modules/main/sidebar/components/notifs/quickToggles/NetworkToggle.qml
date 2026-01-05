import qs.common
import qs.common.widgets
import qs.common.functions
import qs.services

QuickToggleButton {
    property bool showWifiDialog: false
    showButtonName:true
    hasDialog: true

    buttonName: NetworkService.wifiStatus.length > 0 && NetworkService.wifiEnabled ? NetworkService.networkName || StringUtils.capitalizeFirstLetter(NetworkService.wifiStatus) : "Disconnected"
    toggled: NetworkService.networkName.length > 0 && NetworkService.networkName !== "lo"
    buttonIcon: NetworkService.materialSymbol
    onRequestDialog: GlobalStates.showWifiDialog = true
    onClicked: NetworkService.toggleWifi()
}
