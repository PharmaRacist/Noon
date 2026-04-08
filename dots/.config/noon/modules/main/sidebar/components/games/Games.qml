import QtQuick
import qs.common
import qs.common.widgets
import qs.services

StyledRect {
    id: root
    property bool expanded
    property string searchQuery: ""
    property QtObject colors: Colors

    signal searchFocusRequested
    signal contentFocusRequested
    signal dismiss
    signal gameStarted

    onContentFocusRequested: {
        list.currentIndex = 0;
        list.forceActiveFocus();
    }

    clip: true
    radius: Rounding.verylarge
    color: colors.colLayer1

    PagePlaceholder {
        shown: list.count === 0
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
        id: list
        anchors {
            fill: parent
            margins: Padding.large
        }
        hint: false
        currentIndex: -1
        onCurrentIndexChanged: GameLauncherService.selectedIndex = currentIndex

        model: ScriptModel {
            values: searchQuery.length > 0 ? GameLauncherService.searchGames(searchQuery) : GameLauncherService.store.list
        }

        delegate: GameLauncherItem {
            required property var modelData
            required property int index
            anchors.right: parent?.right
            anchors.left: parent?.left
            isSelected: list.currentIndex === index
            itemSize: Sizes.gameLauncherItemSize
            onGameStarted: root.gameStarted()
            colors: root.colors
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Slash && root.focus) {
                root.searchFocusRequested();
            } else if (event.key === Qt.Key_Up) {
                if (currentIndex <= 0) {
                    currentIndex = -1;
                    root.searchFocusRequested();
                } else {
                    currentIndex--;
                }
            } else if (event.key === Qt.Key_Down) {
                if (currentIndex < count - 1) {
                    currentIndex++;
                }
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (currentIndex >= 0) {
                    const selectedData = model.values[currentIndex];
                    if (selectedData && selectedData.executablePath) {
                        GameLauncherService.launchGame(selectedData.id);
                        NoonUtils.playSound("event_accepted");
                    }
                }
            } else if (event.key === Qt.Key_Escape) {
                root.dismiss();
            } else
                return;

            event.accepted = true;
        }
    }

    GameLauncherAddDialog {
        sidebarExpanded: root.expanded
    }
}
