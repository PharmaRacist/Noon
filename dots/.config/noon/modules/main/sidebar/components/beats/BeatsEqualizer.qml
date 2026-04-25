import QtQuick
import QtQuick.Layouts
import qs.services
import qs.common
import qs.common.widgets

StyledRect {
    id: root
    color: Colors.colLayer1
    radius: Rounding.verylarge
    clip: true
    property bool expanded
    property var customBand: ({})
    property var presets: ({})

    readonly property list<string> bandNames: ["31Hz", "62Hz", "125Hz", "250Hz", "500Hz", "1kHz", "2kHz", "4kHz", "8kHz", "16kHz"]

    function setBand(index, value) {
        customBand[index] = value;
        BeatsService.daemonOptions.eq.eqBands = Array.from({
            length: 10
        }, (_, i) => customBand[i] ?? 0);
    }

    function applyPreset(bands) {
        for (let i = 0; i < bands.length; i++) {
            customBand[i] = bands[i];
        }
        BeatsService.daemonOptions.eq.eqBands = bands.slice();
    }

    StyledListView {
        anchors.margins: Padding.huge
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: presetsBg.bottom
        interactive: false
        hint: false
        spacing: Padding.normal
        model: root.bandNames
        delegate: BandItem {
            anchors.right: parent?.right
            anchors.left: parent?.left
            bandName: modelData
            slider.from: -12
            slider.to: 12
            slider.value: BeatsService.daemonOptions.eq.eqBands[index]
            slider.onValueChanged: setBand(index, Math.round(slider.value))
        }
    }
    StyledRect {
        id: presetsBg
        color: Colors.colLayer2
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        width: 300
        height: 85
        ListView {
            orientation: Qt.Horizontal
            spacing: Padding.large
            clip: true
            anchors.fill: parent
            model: BeatsService.daemonOptions.eq.presets
            delegate: BandPresetItem {}
        }
    }

    component BandPresetItem: GroupButtonWithIcon {
        required property var modelData
        required property int index

        anchors.verticalCenter: parent?.verticalCenter
        colBackground: Colors.colLayer3
        implicitSize: 60
        buttonRadius: Rounding.large
        materialIcon: modelData.materialIcon
        releaseAction: () => root.applyPreset(modelData?.bands)

        StyledToolTip {
            content: modelData.name
            extraVisibleCondition: parent.hovered
        }
    }
    component BandItem: StyledRect {
        id: root
        required property string bandName
        required property var modelData
        required property int index
        property alias slider: slider
        radius: Rounding.verylarge
        height: 72
        color: Colors.colLayer2

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Padding.huge
            anchors.rightMargin: Padding.huge
            ColumnLayout {
                Layout.fillWidth: true
                Layout.rightMargin: Padding.huge
                StyledText {
                    Layout.fillWidth: true
                    text: bandName
                    font.family: Fonts.family.monospace
                    font.pixelSize: Fonts.sizes.small
                    color: Colors.colSubtext
                }
                StyledText {
                    Layout.fillWidth: true
                    text: (slider.value >= 0 ? "+" : "") + slider.value + "dB"
                    color: Colors.colOnLayer2
                }
            }

            StyledSlider {
                id: slider
                Layout.minimumWidth: 240
                from: -12
                to: 12
                stepSize: 1
            }
        }
    }
}
