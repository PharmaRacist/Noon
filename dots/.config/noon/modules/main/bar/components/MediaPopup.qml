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
            anchors.leftMargin: Padding.massive
            anchors.rightMargin: Padding.massive
            spacing: Padding.massive

            // Cover Art
            MusicCoverArt {
                visible: BeatsService.artUrl.length > 1
                radius: Rounding.verylarge - Padding.normal
                Layout.preferredWidth: parent.height * 0.86
                Layout.preferredHeight: parent.height * 0.86
            }

            // Track Info
            ColumnLayout {
                Layout.fillWidth: true
                Layout.rightMargin: Padding.massive
                z: 2
                spacing: 0

                StyledText {
                    font.pixelSize: Fonts.sizes.huge
                    font.variableAxes: Fonts.variableAxes.title
                    color: Colors.colOnLayer0
                    text: BeatsService.title || "No Media Playing"
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    wrapMode: TextEdit.Wrap
                    Layout.fillWidth: true
                }

                StyledText {
                    maximumLineCount: 1
                    wrapMode: TextEdit.Wrap
                    font.pixelSize: Fonts.sizes.large
                    font.variableAxes: Fonts.variableAxes.main
                    color: Colors.colSubtext
                    text: BeatsService.artist || "No Current Artist"
                    elide: Text.ElideRight
                }
            }
        }
    }
}
