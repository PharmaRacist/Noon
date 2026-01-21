import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.functions
import qs.common.utils
import qs.common.widgets
import qs.services

StyledRect {
    id: wallpaperItem

    property string fileUrl
    property bool isKeyboardSelected: false
    property bool isCurrentWallpaper: false
    readonly property bool isVideoFile: {
        if (!fileUrl)
            return false;

        const name = fileUrl.toString().toLowerCase();
        for (let i = 0; i < NameFilters.video.length; i++) {
            if (name.endsWith(NameFilters.video[i]))
                return true;
        }
        return false;
    }

    signal clicked

    anchors.fill: parent
    anchors.margins: isKeyboardSelected ? Padding.massive : Padding.normal
    radius: Rounding.large
    color: ColorUtils.transparentize(Colors.colLayer0, isKeyboardSelected ? 0 : 0.8)
    enableBorders: isKeyboardSelected
    clip: true
    Behavior on anchors.margins {
        Anim {}
    }
    StyledRectangularShadow {
        target: imageObject
        enabled: isKeyboardSelected
    }
    CroppedImage {
        id: imageObject

        anchors.fill: parent
        sourceSize: Qt.size(wallpaperItem.cellWidth, wallpaperItem.cellHeight)
        source: isVideoFile ? "" : WallpaperService.getThumbnailPath(wallpaperItem.fileUrl, "large")
        radius: Rounding.large
        asynchronous: true
        visible: !isVideoFile
    }

    VideoPreview {
        id: videoPlayer

        anchors.fill: parent
        source: isVideoFile ? wallpaperItem.fileUrl : ""
        visible: isVideoFile
    }

    Rectangle {
        visible: isVideoFile
        width: 40
        height: 40
        radius: 20
        color: ColorUtils.transparentize(Colors.colLayer0, 0.3)

        anchors {
            top: parent.top
            right: parent.right
            margins: 8
        }

        Symbol {
            anchors.centerIn: parent
            text: "play_circle"
            fill: 1
            color: Colors.m3.m3onSurface
            font.pixelSize: 24
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: event => {
            if (event.button === Qt.RightButton)
                wallpaperMenu.popup(event.x, event.y);
            else if (event.button === Qt.LeftButton)
                wallpaperItem.clicked();
        }
        onEntered: {
            if (isVideoFile && videoPlayer.playbackState !== MediaPlayer.PlayingState)
                videoPlayer.play();
        }
        onExited: {
            if (isVideoFile && videoPlayer.playbackState === MediaPlayer.PlayingState)
                videoPlayer.pause();
        }
    }

    RoundCorner {
        id: checkmark

        corner: cornerEnum.bottomRight
        size: 70
        color: Colors.m3.m3primary
        visible: isCurrentWallpaper
        z: 99

        anchors {
            bottom: parent.bottom
            right: parent.right
        }
    }

    Symbol {
        z: 999
        visible: checkmark.visible
        text: "check"
        fill: 1
        color: Colors.m3.m3onPrimary
        font.pixelSize: 25

        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: 0
        }
    }

    StyledMenu {
        id: wallpaperMenu

        content: [
            {
                "text": "Favorite",
                "materialIcon": "favorite",
                "action": function () {
                    if (wallpaperItem.fileUrl)
                        FileUtils.moveItem(wallpaperItem.fileUrl, Directories.wallpapers.favorite);
                }
            },
            {
                "text": "delete",
                "materialIcon": "delete",
                "action": function () {
                    if (wallpaperItem.fileUrl)
                        FileUtils.deleteItem(wallpaperItem.fileUrl);
                }
            }
        ]
    }
}
