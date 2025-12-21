import Quickshell
import qs.modules.common
import qs.modules.common.widgets
import qs.services

QuickToggleButton {
    id: nightLightButton
    signal requestTempDialog
    buttonName: "NightLight"
    buttonIcon: "nightlight"
    toggled: NightLightService.enabled
    onClicked: NightLightService.toggle()
    altAction:()=>{
        requestTempDialog()
    }
}
