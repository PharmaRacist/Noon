import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services

Item {
    id: root
    anchors.fill: parent
    Component.onCompleted: listView.model.length === 0 ? RadioService.searchQuranStations() : null
    StyledRect {
        id: fabBg
        z: 999
        property bool expanded: listView.model.length === 0
        onExpandedChanged: expanded ? searchBar.forceActiveFocus() : null
        anchors {
            bottom: parent.bottom
            right: parent.right
            bottomMargin: Padding.massive * (RadioService.isPlaying ? 5 : 1)
            margins: Padding.massive
        }
        Behavior on anchors.bottomMargin {
            Anim {}
        }
        width: expanded ? 220 : 64
        height: 64
        radius: Rounding.massive
        color: Colors.colPrimary
        MouseArea {
            anchors.fill: parent
            onClicked: {
                fabBg.expanded = !fabBg.expanded;
            }
        }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Padding.huge
            anchors.rightMargin: Padding.huge
            spacing: Padding.normal

            StyledTextField {
                id: searchBar
                focus: visible
                color: Colors.colOnPrimary
                placeholderTextColor: Colors.colOnPrimary
                visible: fabBg.width > 64
                Layout.fillWidth: true
                placeholderText: "Search stations..."
                background: null
                onAccepted: if (text.length > 0) {
                    RadioService.searchByName(text);
                }

                Keys.onEscapePressed: {
                    fabBg.expanded = false;
                    text = "";
                }
            }

            Symbol {
                text: RadioService.isLoading ? "refresh" : "search"
                color: Colors.colLayer1
                font.pixelSize: 34
                fill: 1
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Padding.large

        StyledText {
            text: "Radio"
            font.pixelSize: Fonts.sizes.subTitle
            color: Colors.colOnLayer1
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: Padding.normal
            Layout.topMargin: Padding.normal
        }

        StyledRect {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "transparent"
            radius: Rounding.huge
            clip: true

            StyledListView {
                id: listView
                anchors.fill: parent
                anchors.topMargin: Padding.small
                model: RadioService.searchResults
                hint: RadioService.searchResults.length === 0 && !RadioService.isLoading
                radius: parent.radius
                spacing: Padding.small

                delegate: StyledDelegateItem {
                    required property var modelData
                    required property int index
                    iconSource: modelData.favicon

                    width: listView.width
                    implicitHeight: 72
                    title: modelData.name

                    materialIcon: if (RadioService.isPlaying && RadioService.currentStation?.stationuuid === modelData.stationuuid) {
                        return "volume_up";
                    } else
                        return "radio"

                    subtext: modelData.country
                    toggled: RadioService.isPlaying && RadioService.currentStation?.stationuuid === modelData.stationuuid
                    onClicked: {
                        if (toggled) {
                            RadioService.stop();
                        } else {
                            RadioService.playStation(modelData);
                        }
                    }
                    ListView {
                        z: 999
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.margins: Padding.small
                        orientation: ListView.Horizontal
                        clip: true
                        spacing: Padding.normal
                        implicitWidth: 64
                        implicitHeight: 32
                        snapMode: ListView.SnapOneItem
                        model: modelData.tags.split(',').filter(tag => tag !== '')
                        delegate: StyledRect {
                            required property var modelData
                            implicitWidth: 64
                            implicitHeight: 32
                            color: Colors.colSecondaryContainer
                            radius: Rounding.full
                            enableBorders: true

                            StyledText {
                                width: parent.width - Padding.small * 2
                                anchors.centerIn: parent
                                truncate: true
                                text: modelData
                                font.weight: 600
                                font.family: Fonts.family.title
                                font.pixelSize: Fonts.sizes.verysmall
                                color: Colors.colOnSecondaryContainer
                            }
                        }
                    }
                }

                PagePlaceholder {
                    anchors.centerIn: parent
                    shown: RadioService.searchResults.length === 0
                    title: RadioService.isLoading ? "Searching..." : "No stations found"
                    description: RadioService.isLoading ? "Finding stations across the globe..." : "Search for stations by name, country, or tag"
                    icon: "radio"
                    shape: MaterialShape.Shape.Cookie6Sided
                    shapePadding: Padding.massive
                }
            }
        }

        // Playback Controls
        StyledRect {
            id: controls
            Layout.fillWidth: true
            Layout.preferredHeight: 72
            visible: RadioService.currentStation?.name.length > 0
            color: Colors.colLayer1
            radius: Rounding.large

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Padding.huge
                anchors.rightMargin: Padding.huge
                spacing: Padding.large

                // Station info
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Padding.normal

                    StyledLoader {
                        sourceComponent: RadioService.currentStation?.favicon.length > 0 ? imageComp : m3comp
                        fade: true
                        onLoaded: if (ready && "source" in item)
                            item.source = Qt.binding(() => RadioService.currentStation?.favicon)
                        property Component imageComp: CroppedImage {
                            width: 42
                            height: 42
                            radius: Rounding.large
                            clip: true
                        }
                        property Component m3comp: MaterialShapeWrappedMaterialSymbol {
                            text: "radio"
                            colSymbol: Colors.colOnPrimary
                            color: Colors.colPrimary
                            implicitSize: 36
                            fill: 1
                            iconSize: 20
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            Layout.fillWidth: true
                            text: RadioService.currentStation?.name ?? ""
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: RadioService.currentStation?.country ?? ""
                            opacity: 0.6
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }
                    }
                }

                // Control buttons
                RowLayout {
                    spacing: Padding.small

                    // Volume control
                    RippleButtonWithIcon {
                        implicitSize: 40
                        materialIcon: RadioService.getVolume() === 0 ? "volume_off" : "volume_up"
                        releaseAction: () => RadioService.toggleMute()
                    }

                    // Play/Pause
                    RippleButtonWithIcon {
                        implicitSize: 48
                        materialIcon: RadioService.isPlaying ? "pause" : "play_arrow"
                        colBackground: Colors.colPrimary
                        iconColor: Colors.colOnPrimary
                        releaseAction: () => RadioService.togglePlayback()
                    }

                    // Stop
                    RippleButtonWithIcon {
                        implicitSize: 40
                        materialIcon: "stop"
                        releaseAction: () => RadioService.stop()
                    }
                }
            }
        }
    }

    // Error notification
    Loader {
        id: errorNotification
        active: RadioService.errorMessage !== ""
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 120

        sourceComponent: StyledRect {
            width: Math.min(400, root.width - Padding.huge * 2)
            height: 56
            color: Colors.colError
            radius: Rounding.large

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Padding.large
                anchors.rightMargin: Padding.large
                spacing: Padding.normal

                Symbol {
                    text: "error"
                    color: Colors.colOnError
                    font.pixelSize: 24
                }

                StyledText {
                    Layout.fillWidth: true
                    text: RadioService.errorMessage
                    color: Colors.colOnError
                    elide: Text.ElideRight
                }

                RippleButtonWithIcon {
                    implicitSize: 32
                    materialIcon: "close"
                    colBackground: "transparent"
                    releaseAction: () => RadioService.errorMessage = ""
                }
            }

            // Auto-hide after 5 seconds
            Timer {
                interval: 5000
                running: true
                onTriggered: RadioService.errorMessage = ""
            }
        }
    }
}
