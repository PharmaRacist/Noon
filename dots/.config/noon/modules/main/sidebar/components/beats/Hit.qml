import QtQuick
import QtQuick.Layouts
import qs.services
import qs.common
import qs.common.widgets

StyledRect {
    id: root
    required property var modelData
    required property int index
    clip: true
    color: Colors.colLayer2
    radius: Rounding.huge

    MouseArea {
        id: eventArea
        z: 99999
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
    }

    StyledRect {
        id: footer
        z: 999
        clip: true
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        color: Colors.colLayer3
        height: eventArea.containsMouse ? parent.height : 45

        GridLayout {
            opacity: eventArea.containsMouse ? 1 : 0
            visible: opacity > 0
            columnSpacing: Padding.huge
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -Padding.huge
            Repeater {
                model: ScriptModel {
                    values: {
                        const l = [
                            {
                                icon: "download",
                                action: () => {
                                    BeatsService.downloadSong(modelData.url);
                                    console.log("Started");
                                }
                            },
                            {
                                visible: BeatsService._playing_online_url !== modelData.url,
                                icon: "play_arrow",
                                action: () => {
                                    BeatsService.playOnline(modelData.url);
                                }
                            }
                        ];
                        return l.filter(i => i?.visible ?? true);
                    }
                }
                delegate: Symbol {

                    text: modelData.icon
                    font.pixelSize: 28
                    fill: 1
                    color: Colors.colOnLayer3
                    MouseArea {
                        id: hoverArea
                        anchors.fill: parent
                        onClicked: modelData.action()
                    }
                }
            }
        }

        ColumnLayout {
            height: 45
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: Padding.veryhuge
            anchors.leftMargin: Padding.veryhuge
            spacing: -Padding.normal

            StyledText {
                font.pixelSize: Fonts.sizes.small
                font.variableAxes: Fonts.variableAxes.title
                text: modelData.title
                Layout.fillWidth: true
                truncate: true
                color: Colors.colOnLayer3
            }

            StyledText {
                font.pixelSize: Fonts.sizes.verysmall
                text: modelData.artist
                Layout.fillWidth: true
                truncate: true
                color: Colors.colSubtext
            }
        }
    }
    Symbol {
        text: "music_note"
        visible: !modelData.thumbnail
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Padding.huge
        font.pixelSize: 54
        color: Colors.colSecondary
    }
    StyledImage {
        anchors.fill: parent
        source: modelData?.thumbnail ?? ""
    }
}
