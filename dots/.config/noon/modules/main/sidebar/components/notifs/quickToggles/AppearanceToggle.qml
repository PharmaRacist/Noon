import Quickshell
import Quickshell.Hyprland
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services

QuickToggleButton {
    toggled: Mem.states.desktop.appearance.mode === "dark"
    buttonIcon: toggled ? "dark_mode" : "light_mode"
    buttonName: toggled ? "Dark" : "Light"
    onClicked: WallpaperService.toggleShellMode()
    hasDialog: true
    onRequestDialog: GlobalStates.main.dialogs.showAppearanceDialog = true
}
