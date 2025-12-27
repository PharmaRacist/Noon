import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

StyledPopup {
    id: root

    Visualizer {
        z: 99
    }

    StyledRect {
        id: bg

        z: 0
        anchors.fill: parent
        implicitWidth: 420
        implicitHeight: 120
        enableBorders: true
        color: "transparent"
        clip: true
        radius: Rounding.verylarge

        BlurImage {
            z: 0
            anchors.fill: parent
            source: BeatsService.artUrl
            asynchronous: true
            blur: true
        }

        RowLayout {
            z: 2
            anchors.fill: parent
            anchors.margins: Padding.large
            anchors.leftMargin: Padding.huge
            anchors.rightMargin: Padding.huge
            spacing: Padding.massive

            // Cover Art
            MusicCoverArt {
                radius: Rounding.verylarge - Padding.normal
                Layout.preferredWidth: parent.height * 0.86
                Layout.preferredHeight: parent.height * 0.86
            }

            // Track Info
            Column {
                z: 2
                spacing: 0

                StyledText {
                    font.pixelSize: Fonts.sizes.huge
                    font.variableAxes: Fonts.variableAxes.title
                    color: Colors.colOnLayer0
                    text: BeatsService.title
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    Layout.fillWidth: true
                    Layout.rightMargin: Padding.massive

                    MouseArea {
                        anchors.fill: parent
                        onPressed: Noon.callIpc("global toggle_beats")
                    }

                }

                StyledText {
                    Layout.fillWidth: true
                    Layout.rightMargin: Padding.massive
                    maximumLineCount: 1
                    font.pixelSize: Fonts.sizes.large
                    font.variableAxes: Fonts.variableAxes.main
                    color: Colors.colSubtext
                    text: BeatsService.artist
                    elide: Text.ElideRight
                }

            }

            Spacer {
            }

        }

    }

}
