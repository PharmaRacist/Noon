import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.common.functions
import qs.services

StyledRect {
    id: root

    z: 99
    radius: Rounding.massive
    color: colors.colLayer1
    colors: parent.colors
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Padding.huge
        spacing: Padding.large

        StyledListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Padding.normal
            spacing: Padding.verysmall
            radius: Rounding.verylarge
            clip: true
            reuseItems: false
            model: filteredModel
            delegate: StyledDelegateItem {
                required property int index
                required property var modelData

                readonly property string hash: modelData.hash ?? ""
                readonly property string fileName: modelData.filename ?? ""
                readonly property string absPath: modelData.filepath
                readonly property bool currentlyPlaying: absPath === BeatsService.currentTrackPath
                buttonRadius: Rounding.tiny
                topRadius: index === 0 ? Rounding.verylarge : Rounding.tiny
                bottomRadius: index === parent?.count - 1 ? Rounding.verylarge : Rounding.tiny
                iconSource: Qt.resolvedUrl(modelData?.cover_art) ?? ""
                implicitHeight: 70
                title: modelData.title ?? "Unknown Track"
                subtext: modelData.artist ?? "Unknown Artist"
                toggled: currentlyPlaying
                colBackground: colors.colLayer3
                colBackgroundHover: colors.colLayer3Hover
                colors: root.colors

                releaseAction: () => BeatsService.playTrack(modelData?.playlist_index)
                altAction: () => trackContextMenu.popup()
            }
        }
    }
}
