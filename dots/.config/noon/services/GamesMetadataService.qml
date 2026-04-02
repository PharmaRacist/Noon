pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.common
import qs.common.utils

Singleton {
    id: root

    property var _coverCache: ({})
    property var _descCache: ({})
    property var _pending: ({})

    readonly property string _coverDir: Directories.services.gamesCoverArts

    function getCover(gameId, gameName, existingCover) {
        if (existingCover && existingCover !== "")
            return existingCover;
        if (!gameName)
            return "";
        if (root._coverCache[gameId])
            return root._coverCache[gameId];
        const path = root._coverDir + "/" + gameId + ".jpg";
        root._coverCache[gameId] = path;
        _fetch(gameId, gameName);
        return path;
    }

    function getDescription(gameId, gameName, existingDesc) {
        if (existingDesc && existingDesc !== "")
            return existingDesc;
        if (!gameName)
            return "";
        if (root._descCache[gameId])
            return root._descCache[gameId];
        if (!root._pending[gameId])
            _fetch(gameId, gameName);
        return "";
    }

    function descriptionReady(gameId) {
        return root._descCache[gameId] ?? "";
    }

    function _fetch(gameId, gameName) {
        if (root._pending[gameId])
            return;
        root._pending[gameId] = true;
        _fetcher.createObject(root, {
            gameId,
            gameName
        });
    }

    Component {
        id: _fetcher
        QtObject {
            id: fetchComp
            property string gameId: ""
            property string gameName: ""
            property string _result: ""

            property var _proc: Process {
                running: true
                command: [Directories.scriptsDir + "/metadata_helper.sh", "--name", fetchComp.gameName, "--id", fetchComp.gameId, "--dir", root._coverDir]
                onStdoutChanged: fetchComp._result += stdout
                onStarted: console.log("GamesMetadata: fetching", command.join(" "))
                onExited: code => {
                    root._pending[fetchComp.gameId] = false;
                    if (code === 0 && fetchComp._result.trim() !== "") {
                        try {
                            const data = JSON.parse(fetchComp._result.trim());
                            if (data.desc)
                                root._descCache[fetchComp.gameId] = data.desc;
                        } catch (_) {}
                    }
                    fetchComp?.destroy();
                }
            }
        }
    }
}
