pragma Singleton
pragma ComponentBehavior: Bound
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.common.utils
import Quickshell
import Qt.labs.platform
import QtQuick

Singleton {
    id: root

    property var currentGame: null
    readonly property var store: Mem.states.services.games

    readonly property int status_not_installed: 0
    readonly property int status_installed: 1
    readonly property int status_playing: 2
    readonly property int status_completed: 3
    readonly property var statusNames: ["Not Installed", "Installed", "Playing", "Completed"]
    property int selectedIndex: 0
    property var selectedInfo: store.list[selectedIndex]
    property alias colors: colorsgen.colors
    property string pendingSelectedGame: ""
    property string pendingSelectedCover: ""
    property alias addDialog: addGamePicker
    property alias addCoverDialog: addCoverPicker

    function setGameMode(toggled) {
        !toggled ? NoonUtils.execDetached("hyprctl reload") : NoonUtils.execDetached(Mem.states.services.games.gameModeCommand);
    }

    function addGame(name, executablePath, coverImage = "", optimization, description = "") {
        const game = {
            "id": Date.now() + Math.random(),
            "name": name,
            "executablePath": executablePath,
            "coverImage": coverImage,
            "description": description,
            "status": status_installed,
            "lastPlayed": null,
            "optimization": optimization,
            "playTime": 0,
            "dateAdded": new Date().toISOString()
        };

        store.list.push(game);
    }
    function deleteGame(gameId) {
        const index = store.list.findIndex(game => game.id === gameId);
        if (index >= 0) {
            store.list.splice(index, 1);
            store.list = store.list.slice(0);
        }
    }
    function launchGame(gameId) {
        const game = store.list.find(g => g.id === gameId);
        if (!game)
            return false;

        game.lastPlayed = new Date().toISOString();
        if (game.status === status_installed) {
            game.status = status_playing;
        }
        if (game.optimization) {
            optimizeSystem();
        }
        currentGame = game;
        gameProcess.running = true;
        return true;
    }
    function getRecentlyPlayed(count = 5) {
        return store.list.filter(game => game.lastPlayed).sort((a, b) => new Date(b.lastPlayed) - new Date(a.lastPlayed)).slice(0, count);
    }
    function searchGames(query) {
        const lowerQuery = query.toLowerCase();
        return store.list.filter(game => game.name.toLowerCase().includes(lowerQuery) || game.description.toLowerCase().includes(lowerQuery));
    }
    function optimizeSystem() {
        NoonUtils.execDetached("hyprctl --batch keyword animations:enabled 0; keyword decoration:shadow:enabled 0; keyword decoration:blur:enabled 0; keyword general:gaps_in 0; keyword general:gaps_out 0; keyword general:border_size 1; keyword input:sensitivity 0; keyword decoration:rounding 0; keyword general:allow_tearing 1");
        NoonUtils.callIpc("global deload");
    }
    Process {
        id: gameProcess
        command: currentGame ? ["gamemoderun", root.currentGame.executablePath] : []
        running: false
        environment: {
            let envObj = {};
            const list = Mem.options.services.games.launchEnv || [];
            list.forEach(item => {
                let [key, val] = item.split('=');
                if (key && val)
                    envObj[key] = val;
            });
            return envObj;
        }
        workingDirectory: {
            if (!root.currentGame)
                return "";
            const path = root.currentGame.executablePath;
            return path.substring(0, path.lastIndexOf('/'));
        }
        onStarted: NoonUtils.toast("Game Launched", "stadia_controller")
        onExited: {
            NoonUtils.callIpc("global load");
            NoonUtils.execDetached("hyprctl reload");
        }
    }

    FileDialog {
        id: addGamePicker
        title: "Select Game Executable"
        nameFilters: ["Executable files (*.exe *.AppImage *.sh)", "All files (*)"]
        onAccepted: {
            root.pendingSelectedGame = FileUtils.trimFileProtocol(currentFile);
            NoonUtils.callIpc("sidebar reveal Games");
        }
    }

    FileDialog {
        id: addCoverPicker
        title: "Select Cover Executable"
        nameFilters: ["Image files (*.png *.jpg *.jpeg)", "All files (*)"]
        onAccepted: {
            root.pendingSelectedCover = FileUtils.trimFileProtocol(currentFile);
            NoonUtils.callIpc("sidebar reveal Games");
        }
    }

    PaletteGenerator {
        id: colorsgen
        active: Mem.options.services.games.adaptiveTheme
        source: (root.selectedInfo && root.selectedInfo.coverImage) ? root.selectedInfo.coverImage : ""
    }
}
