import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.common
import qs.common.widgets
import qs.services

StyledRect {
    id: root
    property size itemSize
    property bool collapsed
    width: collapsed ? parent.width : itemSize.width - Padding.verylarge
    height: collapsed ? 125 : itemSize.height - Padding.verylarge
    radius: Rounding.verylarge
    color: colors.colLayer1
    property size coverArtSize: collapsed ? Qt.size(75, 75) : Qt.size(175, 175)
    signal gameStarted
    property QtObject colors: Colors
    GridLayout {
        anchors.fill: parent
        anchors.margins: Padding.massive
        columnSpacing: Padding.verylarge
        rowSpacing: Padding.large
        rows: collapsed ? 1 : 4
        columns: collapsed ? 4 : 1

        StyledRect {
            Layout.preferredWidth: root.coverArtSize.width
            Layout.preferredHeight: root.coverArtSize.height
            radius: Rounding.verylarge
            color: root.colors.colLayer2
            clip: true

            Image {
                id: coverImage
                anchors.fill: parent
                source: root.gameData.coverImage && root.gameData.coverImage !== "" ? (root.gameData.coverImage.startsWith("file://") ? root.gameData.coverImage : "file://" + root.gameData.coverImage) : ""
                smooth: true
                asynchronous: true
            }

            MaterialSymbol {
                anchors.centerIn: parent
                text: "sports_esports"
                font.pixelSize: 54
                fill: 1
                color: root.colors.colOnLayer0
                visible: !root.gameData.coverImage || root.gameData.coverImage === "" || coverImage.status === Image.Error
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            StyledText {
                text: root.gameData.name
                font.pixelSize: Fonts.sizes.verylarge
                font.weight: Font.Medium
                color: root.colors.colOnLayer2
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            StyledText {
                // visible: false
                text: GameLauncherService.statusNames[root.gameData.status]
                font.pixelSize: Fonts.sizes.small
                color: root.colors.colSubtext
            }
        }
        Spacer {}
        RowLayout {
            Layout.preferredHeight: 40
            Layout.fillWidth: true
            spacing: Padding.large
            RippleButton {
                Layout.fillWidth: !root.collapsed
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                buttonRadius: Rounding.normal
                colBackground: root.colors.colPrimary
                onPressed: {
                    root.gameStarted();
                    GameLauncherService.launchGame(root.gameData.id);
                }
                RowLayout {
                    anchors.centerIn: parent
                    MaterialSymbol {
                        Layout.fillWidth: !root.collapsed
                        text: "play_arrow"
                        color: root.colors.colOnPrimary
                        fill: 1
                        font.pixelSize: 24
                    }
                    StyledText {
                        visible: !root.collapsed
                        text: "Play"
                        color: root.colors.colOnPrimary
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
            RippleButtonWithIcon {
                implicitSize: 36
                buttonRadius: Rounding.normal
                colBackground: root.colors.colSecondaryContainer
                materialIcon: "delete"
                releaseAction: () => {
                    deleteConfirmDialog.gameToDelete = root.gameData;
                    deleteConfirmDialog.open();
                }
            }
        }
    }
}
