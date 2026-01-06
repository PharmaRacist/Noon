import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.common
import qs.common.utils
import qs.modules.main.view
import qs.common.functions
import qs.common.widgets
import qs.services
import qs.store

Scope {
    IpcHandler {
        target: "noon"
        function expose(show: bool) {
            if (show) {
                GlobalStates.main.exposeView = true;
            } else if (!show) {
                GlobalStates.main.exposeView = false;
            }
        }
        function inc_brightness() {
            BrightnessService.increaseBrightness();
        }

        function dec_brightness() {
            BrightnessService.decreaseBrightness();
        }
        function clear_clipboard() {
            ClipboardService.wipe();
        }
        function update_clipboard() {
            ClipboardService.reload();
            SidebarData.generateHistory();
        }
        function refresh_appearance() {
            WallpaperService.refreshTheme();
        }
        function toggleLightMode() {
            WallpaperService.toggleShellMode();
        }
        function pick_accent() {
            WallpaperService.pickAccentColor();
            Noon.notify("Color Changed");
        }
        function pick_random_wall() {
            WallpaperService.applyRandomWallpaper();
            Noon.notify("Picked Random Wall");
        }
        function set_wall(path: string) {
            WallpaperService.applyWallpaper(path);
            Noon.notify("Wallpaper Changed");
        }
        function toggle_bar_mode() {
            Mem.options.bar.behavior.position = BarData.getNextMode();
        }
        function swap_bar_position() {
            BarData.swapPosition();
        }
        function toggle_dock_pin() {
            Mem.states.dock.pinned = !Mem.states.dock.pinned;
        }
        function toggle_osk() {
            GlobalStates.main.oskOpen = !GlobalStates.main.oskOpen;
        }
        function todoist_key(key: string) {
            const trimmed = key.trim();
            KeyringStorage.setNestedField(["todoistApiKey"], trimmed);
            TodoService.todoistApiToken = trimmed;
            console.log("API token set (trimmed):", TodoService.todoistApiToken);
        }

        function add_alarm(time: string, name: string) {
            AlarmService.addTimer(time, name);
        }
        function wake(message: string) {
            Noon.wake(message, "alarm");
        }

        function edit_json() {
            Noon.edit(Quickshell.env('SHELL_CONFIG_PATH'));
        }
        function lock() {
            GlobalStates.main.locked = true;
            IdleService.idleMonitor.reset();
        }
        function pause_all_players(): void {
            for (const player of Mpris.players.values) {
                if (player.canPause)
                    player.pause();
            }
        }

        function toggle_playing(): void {
            MprisController.togglePlaying();
        }
        function previous_track(): void {
            MprisController.previous();
        }
        function next_track(): void {
            MprisController.next();
        }
        function medical_key(key: string) {
            MedicalDictionaryService.setApiKey(key);
        }
        function toggle_ai_bar() {
            GlobalStates.main.showBeam = !GlobalStates.main.showBeam;
        }
    }
}
