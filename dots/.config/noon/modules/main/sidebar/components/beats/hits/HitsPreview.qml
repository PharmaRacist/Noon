import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

RowLayout {
    id: root
    property bool isCurrent: BeatsService.previewData?.url === "songData.url"
    property var songData
    spacing: Padding.massive
    MusicCoverArt {
        implicitSize: 136
        source: songData?.thumbnail ?? ""
    }
    ColumnLayout {
        Layout.fillWidth: true
        StyledText {
            font.weight: 800
            Layout.fillWidth: true
            font.pixelSize: Fonts.sizes.large
            truncate: true
            wrapMode: Text.Wrap
            maximumLineCount: 3
            text: songData?.title ?? "No Title"
        }
        StyledText {
            font.pixelSize: Fonts.sizes.verysmall
            Layout.fillWidth: true
            text: songData?.artist ?? "No Artist"
            color: Colors.colSubtext
        }
        ButtonGroup {
            Layout.topMargin: Padding.large
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            Layout.fillWidth: false
            Layout.fillHeight: false
            Repeater {
                model: ScriptModel {
                    values: {
                        const l = [
                            {
                                icon: "download",
                                action: () => {
                                    BeatsService.downloadSong(songData.url);
                                }
                            },
                            {
                                toggled: root.isCurrent,
                                icon: BeatsService._playing ? "pause" : "play_arrow",
                                action: () => {
                                    if (!isCurrent)
                                        BeatsService.previewURL(songData?.url);
                                }
                            }
                        ];
                        return l;
                    }
                }

                delegate: GroupButtonWithIcon {
                    baseSize: 45
                    buttonRadius: Rounding.small
                    buttonRadiusPressed: Rounding.large
                    toggled: modelData?.toggled ?? false
                    materialIcon: modelData.icon
                    releaseAction: () => modelData.action()
                }
            }
        }
    }
}
