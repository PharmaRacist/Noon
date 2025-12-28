import QtQuick
import qs.common
import qs.common.widgets
import qs.services

StyledRect {
    id: root
    property bool expanded
    property string searchQuery: ""
    property int selectedIndex: 0
    property QtObject colors: GameLauncherService.colors
    signal gameStarted
    clip: true
    radius: Rounding.verylarge
    color: "transparent"
    Binding {
        target: GameLauncherService
        property: "selectedIndex"
        value: root.selectedIndex
    }
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
    StyledGridView {
        anchors {
            fill: parent
            margins: Padding.massive
        }
        cellWidth: Sizes.gameLauncherItemSize.width
        cellHeight: !root.expanded ? 130 : Sizes.gameLauncherItemSize.height
        cacheBuffer: Math.min(500, cellHeight * 3)
        displayMarginBeginning: cellHeight
        displayMarginEnd: cellHeight
        reuseItems: true
        model: searchQuery.length > 0 ? GameLauncherService.searchGames(searchQuery) : GameLauncherService.gamesList
        delegate: GameLauncherItem {
            colors: GameLauncherService.colors
            itemSize: Sizes.gameLauncherItemSize
            property var gameData: modelData
            onGameStarted: root.gameStarted()
            collapsed: !root.expanded
        }
    }
    GameLauncherAddDialog {
        sidebarExpanded: root.expanded
    }
}
