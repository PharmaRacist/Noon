import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Item {
    anchors.fill: parent
    visible: ytMusicTab.searchLoading

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 24

        // Custom Material 3 loading animation
        Item {
            Layout.alignment: Qt.AlignHCenter
            width: 120
            height: 120

            // Outer pulsing circle
            Rectangle {
                id: outerCircle

                anchors.centerIn: parent
                width: 100
                height: 100
                radius: 50
                color: "transparent"
                border.width: 3
                border.color: Appearance.colors.m3.m3primary
                opacity: 0.3

                SequentialAnimation on opacity {
                    running: ytMusicTab.searchLoading
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 0.8
                        duration: 1200
                        easing.type: Easing.InOutSine
                    }

                    NumberAnimation {
                        to: 0.3
                        duration: 1200
                        easing.type: Easing.InOutSine
                    }

                }

                SequentialAnimation on scale {
                    running: ytMusicTab.searchLoading
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 1.1
                        duration: 1200
                        easing.type: Easing.InOutSine
                    }

                    NumberAnimation {
                        to: 1
                        duration: 1200
                        easing.type: Easing.InOutSine
                    }

                }

            }

            // Inner spinning circle
            Rectangle {
                id: innerCircle

                anchors.centerIn: parent
                width: 70
                height: 70
                radius: 35
                color: "transparent"
                border.width: 4
                border.color: Appearance.colors.m3.m3primary

                // Create spinning effect with gradient-like appearance
                Rectangle {
                    anchors.fill: parent
                    radius: 35
                    color: "transparent"
                    border.width: 4
                    border.color: "transparent"
                }

                RotationAnimation on rotation {
                    running: ytMusicTab.searchLoading
                    from: 0
                    to: 360
                    duration: 2000
                    loops: Animation.Infinite
                    easing.type: Easing.Linear
                }

            }

            // Center music note icon
            Rectangle {
                anchors.centerIn: parent
                width: 40
                height: 40
                radius: 20
                color: Appearance.colors.m3.m3primaryContainer

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "music_note"
                    font.pixelSize: 24
                    color: Appearance.colors.m3.m3primary
                }

            }

        }

        // Enhanced loading text with typing effect
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 14

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Appearance.fonts.sizes.normal
                color: Appearance.colors.m3.m3onSurfaceVariant
                opacity: 0.8
                text: ytMusicTab.searchResults.length > 0 ? qsTr("Found %1 results, loading more...").arg(ytMusicTab.searchResults.length) : qsTr("This might take a few seconds")
                visible: text.length > 0
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8

                Repeater {
                    model: 3

                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: Appearance.colors.m3.m3primary

                        SequentialAnimation on opacity {
                            running: ytMusicTab.searchLoading
                            loops: Animation.Infinite

                            PauseAnimation {
                                duration: index * 200
                            }

                            NumberAnimation {
                                to: 1
                                duration: 400
                                easing.type: Easing.InOutSine
                            }

                            NumberAnimation {
                                to: 0.3
                                duration: 400
                                easing.type: Easing.InOutSine
                            }

                            PauseAnimation {
                                duration: (2 - index) * 200
                            }

                        }

                        SequentialAnimation on scale {
                            running: ytMusicTab.searchLoading
                            loops: Animation.Infinite

                            PauseAnimation {
                                duration: index * 200
                            }

                            NumberAnimation {
                                to: 1.3
                                duration: 400
                                easing.type: Easing.OutBack
                            }

                            NumberAnimation {
                                to: 1
                                duration: 400
                                easing.type: Easing.InBack
                            }

                            PauseAnimation {
                                duration: (2 - index) * 200
                            }

                        }

                    }

                }

            }

        }

    }

}
