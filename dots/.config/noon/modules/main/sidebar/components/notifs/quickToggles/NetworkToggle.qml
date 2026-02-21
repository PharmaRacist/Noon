import qs.common
import qs.common.widgets
import qs.common.functions
import qs.services

QuickToggleButton {
    dialogName: "Wifi"
    buttonName: NetworkService.wifiStatus.length > 0 && NetworkService.wifiEnabled ? NetworkService.networkName || StringUtils.capitalizeFirstLetter(NetworkService.wifiStatus) : "Disconnected"
    buttonSubtext: NetworkService.wifiEnabled ? "enabled" : "disabled"
    toggled: NetworkService.networkName.length > 0 && NetworkService.networkName !== "lo"
    buttonIcon: NetworkService.materialSymbol
    onClicked: NetworkService.toggleWifi()
}
