import qs.common
import qs.services

QuickToggleButton {
    toggled: Mem.states.desktop.appearance.mode === "dark"
    buttonIcon: toggled ? "dark_mode" : "light_mode"
    buttonName: toggled ? "Dark" : "Light"
    onClicked: WallpaperService.toggleShellMode()
    dialogName: "Appearance"
}
