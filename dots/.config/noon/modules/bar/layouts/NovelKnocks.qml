import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Services.UPower
import qs.modules.bar.components
import qs.modules.common
import qs.modules.common.widgets
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
            Spacer {}
            Resources {}
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

            Logo {}
            StackedClockWidget {
                Layout.fillWidth: true
            }
            Spacer {}
            StatusIcons {}
        }
    }

    // Chunk with inner rectangle
    component Chunk: StyledRect {
        id: root
        enableShadows: true
        color: Colors.colLayer0
        radius: Rounding.verylarge
        implicitHeight: barHeight
        Layout.alignment: Qt.AlignVCenter
        default property alias contents: innerLayout.children

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
        enableShadows: true
        color: Colors.colLayer0
        radius: Rounding.verylarge
        implicitHeight: barHeight
        default property alias contents: layout.children

        RowLayout {
            id: layout
            anchors.fill: parent
            anchors.leftMargin: Padding.small
            anchors.rightMargin: Padding.small
            spacing: Padding.small
        }
    }
}
