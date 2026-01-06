import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Services.UPower
import qs.common
import qs.common.widgets
import qs.modules.main.bar.components
import qs.store

Item {
    id: barBackground

    property var barRoot
    property int chunkWidth: 380
    readonly property int barHeight: height

    anchors {
        fill: parent
        margins: Sizes.barElevation
    }

    RowLayout {
        id: chunksRow

        anchors.centerIn: barBackground
        spacing: Padding.large

        // Left Chunk
        Chunk {
            implicitWidth: 400

            Media {
                expand: true
                Layout.fillWidth: true
            }

            Spacer {
            }

            Resources {
            }

        }

        // Middle Chunk (Workspaces)
        Chunk {
            implicitWidth: workspaces.implicitWidth + 25
            Layout.alignment: Qt.AlignCenter

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                Workspaces {
                    id: workspaces

                    borders: false
                    anchors.centerIn: parent
                    Layout.alignment: Qt.AlignCenter
                    bar: barRoot
                }

            }

        }

        // Right Chunk
        Chunk {
            implicitWidth: chunkWidth
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            Logo {
            }

            StackedClockWidget {
                Layout.fillWidth: true
            }

            Spacer {
            }

            StatusIcons {
            }

        }

    }

    // Chunk with inner rectangle
    component Chunk: StyledRect {
        id: root

        default property alias contents: innerLayout.children

        color: Colors.colLayer0
        radius: Rounding.verylarge
        implicitHeight: barHeight
        Layout.alignment: Qt.AlignVCenter

        StyledRect {
            anchors.fill: parent
            anchors.margins: Padding.small
            color: Colors.colLayer2
            radius: root.radius - Padding.small

            RowLayout {
                id: innerLayout

                anchors.fill: parent
                anchors.leftMargin: Padding.large
                anchors.rightMargin: Padding.large
                spacing: 18
            }

        }

    }

    // Simple chunk without inner rectangle
    component SimpleChunk: StyledRect {
        default property alias contents: layout.children

        color: Colors.colLayer0
        radius: Rounding.verylarge
        implicitHeight: barHeight

        RowLayout {
            id: layout

            anchors.fill: parent
            anchors.leftMargin: Padding.small
            anchors.rightMargin: Padding.small
            spacing: Padding.small
        }

    }

}
