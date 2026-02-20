import QtQuick
import qs.common
import qs.common.widgets
import qs.services

StyledRect {
    id: root
    property bool expanded
    property string searchQuery: ""
    property QtObject colors: GameLauncherService.colors
    signal gameStarted
    clip: true
    radius: Rounding.verylarge
    color: "transparent"
    PagePlaceholder {
        shown: GameLauncherService.gamesList.length === 0
        title: "No Games Avilable"
        icon: "stadia_controller"
        iconSize: 128
        description: "Swipe Below to Add New Games"
        shape: MaterialShape.Shape.Ghostish
        colBackground: root.colors.colSecondaryContainer
        colOnBackground: root.colors.colOnSecondaryContainer
    }
    Loader {
        z: -1
        anchors.fill: parent
        active: Mem.options.services.games.adaptiveTheme
        sourceComponent: BlurImage {
            anchors.fill: parent
            tint: true
            tintLevel: 0.9
            tintColor: root.colors.colTint
            source: Qt.resolvedUrl(GameLauncherService.selectedInfo.coverImage)
            blur: true
        }
    }
    StyledListView {
        id: listView

        anchors {
            fill: parent
            margins: Padding.massive
        }

        onCurrentIndexChanged: GameLauncherService.selectedIndex = currentIndex
        model: searchQuery.length > 0 ? GameLauncherService.searchGames(searchQuery) : GameLauncherService.gamesList
        delegate: GameLauncherItem {
            colors: GameLauncherService.colors
            itemSize: Sizes.gameLauncherItemSize
            property var gameData: modelData
            onGameStarted: root.gameStarted()
            collapsed: true
        }
    }
    GameLauncherAddDialog {
        sidebarExpanded: root.expanded
    }
}
