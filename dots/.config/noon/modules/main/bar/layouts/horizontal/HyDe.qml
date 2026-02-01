import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import qs.common
import qs.common.widgets
import qs.modules.main.bar.components
import qs.services

Item {
    property var barRoot
    property bool bordered: false
    property int chunkWidth: 350
    property int chunkHeight: parent.height
    property real commonRadius: Rounding.verylarge
    property real borderWidth: 1
    property color borderColor: bordered ? Colors.colSecondary : "transparent"
    readonly property bool shouldShow: Screen.width > 1080 ?? false

    anchors.fill: parent
    anchors.rightMargin: Padding.huge

    RowLayout {
        spacing: 10
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        MinimalBattery {
            id: battery

            visible: UPower.displayDevice.isLaptopBattery
        }

        Rectangle {
            id: wsChunk

            Layout.preferredWidth: workspaces.width + 16
            Layout.preferredHeight: chunkHeight
            color: Colors.colLayer0
            radius: commonRadius
            border.color: borderColor
            border.width: borderWidth

            RectangularShadow {
                visible: !Mem.options.appearance.transparency
                anchors.fill: wsChunk
                radius: commonRadius
                blur: 1.2 * Sizes.elevationMargin
                spread: 2
                color: Colors.colShadow
            }

            MouseArea {
                width: wsChunk.width
                height: wsChunk.height
                acceptedButtons: Qt.RightButton
                onClicked: event => {
                    if (event.button === Qt.RightButton)
                        NoonUtils.callIpc("sidebar reveal View");
                }
            }

            RowLayout {
                width: parent.width
                height: parent.height

                ProgressWs {
                    id: workspaces

                    Layout.alignment: Qt.AlignCenter
                    bar: barRoot
                }
            }
        }

        Rectangle {
            visible: false
            height: chunkHeight
            width: 200
            radius: commonRadius
            color: Colors.colLayer0
            clip: true
            border.color: borderColor
            border.width: borderWidth

            InlineWindowTitle {
                bar: barRoot
                anchors.fill: parent
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Rectangle {
            id: rightChunk

            width: indicatorsAreaRow.width + 50
            height: chunkHeight
            color: Colors.colLayer0
            radius: commonRadius
            border.color: borderColor
            border.width: borderWidth

            RectangularShadow {
                visible: !Mem.options.appearance.transparency
                anchors.fill: parent
                radius: parent.radius
                blur: 1.2 * Sizes.elevationMargin
                spread: 2
                color: Colors.colShadow
            }

            RowLayout {
                id: indicatorsAreaRow

                spacing: 10
                anchors.centerIn: parent
                Layout.fillWidth: true

                SysTray {
                    bar: barRoot
                    Layout.fillWidth: true
                    visible: SystemTray.items.values.length > 0
                }

                StatusIcons {}

                Logo {}
            }
        }
    }

    Rectangle {
        id: centerChunk

        width: 320
        color: Colors.colLayer0
        height: chunkHeight
        radius: commonRadius
        border.color: borderColor
        border.width: borderWidth
        anchors.centerIn: parent

        RectangularShadow {
            visible: !Mem.options.appearance.transparency
            anchors.fill: parent
            radius: parent.radius
            blur: 1.2 * Sizes.elevationMargin
            spread: 2
            color: Colors.colShadow
        }

        RowLayout {
            anchors.fill: parent
            spacing: 20
            anchors.rightMargin: 16
            anchors.leftMargin: 16

            Weather {
                Layout.preferredHeight: 18
                Layout.preferredWidth: 40
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillHeight: true
                width: 1
                color: Colors.colOutline
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                Layout.alignment: Qt.AlignHCenter
            }

            StyledText {
                id: clock
                font {
                    family: Fonts.family.title
                    variableAxes: Fonts.variableAxes.title
                    pointSize: Fonts.sizes.normal
                }
                color: Colors.colOnLayer0
                text: Qt.formatTime(DataTimeService.clock.date, "hh:mm")
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
