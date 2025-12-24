import qs.modules.common
import qs.modules.common.widgets
import qs.services
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.Pipewire

GroupButton {
    id: button
    required property bool input

    buttonRadius: Rounding.verylarge
    colBackground: Colors.colLayer2
    colBackgroundHover: Colors.colLayer2Hover
    colBackgroundActive: Colors.colLayer2Active
    clickedWidth: baseWidth + 30

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 10

        MaterialSymbol {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: false
            Layout.leftMargin: 5
            color: Colors.colOnLayer2
            font.pixelSize: Fonts.sizes.huge
            text: input ? "mic_external_on" : "media_output"
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.rightMargin: 5
            spacing: 0
            StyledText {
                Layout.fillWidth: true
                elide: Text.ElideRight
                font.pixelSize: Fonts.sizes.normal
                text: input ? qsTr("Input") : qsTr("Output")
                color: Colors.colOnLayer2
            }
            StyledText {
                Layout.fillWidth: true
                elide: Text.ElideRight
                font.pixelSize: Fonts.sizes.verysmall
                text: (input ? Pipewire.defaultAudioSource?.description : Pipewire.defaultAudioSink?.description) ?? qsTr("Unknown")
                color: Colors.m3.m3outline
            }
        }
    }
}
