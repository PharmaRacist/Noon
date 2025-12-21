import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Item {
    id: root

    property var presetList: []
    property string emptyPlaceholderText: qsTr("No presets")
    property string emptyPlaceholderIcon: "apps"
    property int listBottomPadding: 0

    signal createFromPreset(var preset)

    function formatTime(seconds) {
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        const secs = seconds % 60;
        if (hours > 0)
            return hours + "h " + minutes + "m";
        else if (minutes > 0)
            return minutes + "m";
        else
            return secs + "s";
    }

    GridView {
        id: gridView

        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: root.listBottomPadding
        cellWidth: parent.width // Math.floor(width / Math.max(1, Math.floor(width / 160))) + 10
        cellHeight: 80
        model: root.presetList
        clip: true

        delegate: Item {
            width: gridView.cellWidth
            height: gridView.cellHeight

            Rectangle {
                id: presetCard

                anchors.fill: parent
                anchors.margins: 2
                radius: Rounding.normal
                color: Colors.colLayer1

                MouseArea {
                    id: presetMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.createFromPreset(modelData)

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.parent.radius
                        color: Colors.m3.m3primary
                        opacity: presetMouseArea.pressed ? 0.1 : (presetMouseArea.containsMouse ? 0.05 : 0)

                        Behavior on opacity {
                            Anim {}

                        }

                    }

                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    Rectangle {
                        radius: Rounding.normal
                        color: Colors.m3.m3primaryContainer
                        implicitHeight: 45
                        implicitWidth: 45

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: modelData.icon
                            fill: 1
                            font.pixelSize: parent.height * 0.5
                            color: Colors.m3.m3onPrimaryContainer
                        }

                    }

                    StyledText {
                        Layout.leftMargin: 10
                        Layout.fillWidth: false
                        text: modelData.name
                        color: Colors.m3.m3onSurface
                        font.pixelSize: Fonts.sizes.normal
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.formatTime(modelData.duration)
                        color: Colors.m3.m3primary
                        font.pixelSize: Fonts.sizes.small
                        font.weight: Font.DemiBold
                    }

                }

            }

        }

    }

}
