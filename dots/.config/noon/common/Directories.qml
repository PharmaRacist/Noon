pragma Singleton
import QtQuick
import Quickshell
import Qt.labs.platform
import qs.common.functions

Singleton {
    id: root
    // misc directories
    readonly property string venv: standard.state + "/.venv"
    readonly property string sounds: FileUtils.trimFileProtocol(`${assets}/sounds/`)
    readonly property string assets: FileUtils.trimFileProtocol(`${standard.config}/noon/assets`)
    readonly property string gallery: FileUtils.trimFileProtocol(`${standard.pictures}/Gallary/`)
    readonly property string shellConfigs: FileUtils.trimFileProtocol(`${standard.config}/HyprNoon/`)
    readonly property string shellDir: FileUtils.trimFileProtocol(`${standard.config}/noon`)
    readonly property string scriptsDir: shellDir + "/scripts"
    readonly property string favicons: FileUtils.trimFileProtocol(`${standard.cache}/media/favicons`)
    Component.onCompleted: FileUtils.mkdir([venv, assets, gallery, sounds, scriptsDir, shellConfigs, favicons])

    // standard directories
    readonly property QtObject standard: QtObject {
        readonly property string config: StandardPaths.standardLocations(StandardPaths.ConfigLocation)[0]
        readonly property string state: home + "/.local/state/noon"
        readonly property string cache: home + "/.cache/noon"
        readonly property string pictures: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
        readonly property string downloads: StandardPaths.standardLocations(StandardPaths.DownloadLocation)[0]
        readonly property string music: StandardPaths.standardLocations(StandardPaths.MusicLocation)[0]
        readonly property string documents: StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]
        readonly property string videos: StandardPaths.standardLocations(StandardPaths.MoviesLocation)[0]
        readonly property string home: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
        Component.onCompleted: FileUtils.mkdir([state, cache])
    }

    // services directories
    readonly property QtObject services: QtObject {
        readonly property string notifications: FileUtils.trimFileProtocol(`${standard.cache}/notifications/notifications.json`)
        readonly property string latex: FileUtils.trimFileProtocol(`${standard.cache}/media/latex`)
        readonly property string aiChats: FileUtils.trimFileProtocol(`${standard.state}/user/generated/ai`)
        readonly property string m3path: FileUtils.trimFileProtocol(`${standard.state}/user/generated/colors.json`)
        Component.onCompleted: FileUtils.mkdir([notifications, latex, aiChats, m3path])
    }

    // wallpapers directories
    readonly property QtObject wallpapers: QtObject {
        readonly property string switchScript: FileUtils.trimFileProtocol(`${root.scriptsDir}/appearance_service.py`)
        readonly property string main: FileUtils.trimFileProtocol(`${standard.pictures}/Wallpapers/`)
        readonly property string depthDir: FileUtils.trimFileProtocol(`${standard.cache}/user/generated/depth/`)
        readonly property string gowallDir: FileUtils.trimFileProtocol(`${standard.cache}/user/generated/gowall/`)
        readonly property string favorite: FileUtils.trimFileProtocol(`${standard.pictures}/favourite`)
        Component.onCompleted: FileUtils.mkdir([main, switchScript, depthDir, gowallDir, favorite])
    }

    // beats directories
    readonly property QtObject beats: QtObject {
        readonly property string main: FileUtils.trimFileProtocol(`${standard.cache}/beats`)
        readonly property string downloads: FileUtils.trimFileProtocol(`${standard.home}/Downloads`)
        readonly property string coverArt: FileUtils.trimFileProtocol(`${main}/coverart`)
        readonly property string lyrics: FileUtils.trimFileProtocol(`${main}/lyrics`)
        readonly property string tracks: FileUtils.trimFileProtocol(standard.music)
        Component.onCompleted: FileUtils.mkdir([main, coverArt, lyrics, tracks])
    }
}
