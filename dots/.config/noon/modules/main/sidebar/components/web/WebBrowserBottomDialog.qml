import qs.services
import qs.common
import qs.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell

BottomDialog {
    id: root
    property int iconSize: (width - 2 * Padding.massive) / 4
    property string url: ""
    collapsedHeight: Math.min((iconSize + 20) * grid.rows), parent.height * 0.4
    show: GlobalStates.main.dialogs.showWifiDialog
    enableStagedReveal: false
    bottomAreaReveal: true
    hoverHeight: 120
    enableShadows: true

    contentItem: Item {
        clip: true
        anchors.fill: parent
        StyledFlickable {
            id: contentFlickable
            anchors.fill: parent
            anchors.margins: Padding.normal
            clip: true

            contentWidth: root.iconSize * 2
            contentHeight: root.iconSize * 2

            ColumnLayout {
                anchors.fill: parent
                BottomDialogHeader {
                    title: "Current Favourites"
                    subTitle: "You Have " + repeater.model.length + " Bookmarks"
                    target: root
                }
                BottomDialogSeparator {}
                GridLayout {
                    id: grid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 4
                    rowSpacing: Padding.small
                    columnSpacing: Padding.small
                    Repeater {
                        id: repeater
                        model: FirefoxBookmarksService.bookmarks
                        BookmarkButton {
                            required property var modelData
                            iconSource: modelData.favicon_local
                            title: modelData.title
                            iconSize: root.iconSize
                            url: modelData.url
                        }
                    }
                }
            }
        }
    }
    component BookmarkButton: StyledRect {
        id: root
        property alias iconSource: img.source
        property int iconSize
        property alias title: title.text
        property string url
        implicitHeight: iconSize
        implicitWidth: iconSize
        color: Colors.colLayer1
        radius: Rounding.verylarge
        clip: true
        BlurImage {
            id: img
            anchors.fill: parent
            blur: !eventArea.containsMouse
            sourceSize: Qt.size(width, height)
            asynchronous: true
            cache: false
        }
        Rectangle {
            z: 999
            opacity: 0.15
            color: eventArea.containsMouse ? "transparent" : Colors.colSecondaryContainer
            anchors.fill: parent
            StyledText {
                id: title
                width: parent.width / 1.5
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                maximumLineCount: 2

                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                    bottomMargin: Padding.normal
                }
                font {
                    pixelSize: Fonts.sizes.small
                    family: Fonts.family.title
                    variableAxes: Fonts.variableAxes.title
                }
                color: Colors.colOnLayer0
            }
        }
        StyledToolTip {
            extraVisibleCondition: eventArea.containsMouse
            content: root.url
        }
        MouseArea {
            id: eventArea
            anchors.fill: parent
            hoverEnabled: true
            onPressed: () => {
                GlobalStates.web_session.url = root.url;
            }
        }
    }
}
