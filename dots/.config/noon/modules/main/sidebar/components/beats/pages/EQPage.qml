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
    readonly property var store: BeatsService.daemonOptions
    property bool expanded
    property var customBand: ({})
    property var presets: ({})

    readonly property list<string> bandNames: ["31Hz", "62Hz", "125Hz", "250Hz", "500Hz", "1kHz", "2kHz", "4kHz", "8kHz", "16kHz"]

    function setBand(index, value) {
        customBand[index] = value;
        const targetBands = Array.from({
            length: 10
        }, (_, i) => customBand[i] ?? 0);
        writeBands(targetBands);
    }
    function writeBands(bands) {
        store.players.preview.eq.eqBands = bands;
        store.players.main.eq.eqBands = bands;
    }
    function applyPreset(bands) {
        for (let i = 0; i < bands.length; i++) {
            customBand[i] = bands[i];
        }
        const targetBands = bands.slice();
        writeBands(targetBands);
    }

    StyledListView {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: presetsBg.top
            margins: Padding.huge
        }
        interactive: false
        hint: false
        spacing: Padding.normal
        model: root.bandNames

        delegate: BandItem {
            anchors.left: parent?.left
            anchors.right: parent?.right
            bandName: modelData
            slider.from: -12
            slider.to: 12
            slider.value: store.players.main.eq.eqBands[index]
            slider.onValueChanged: setBand(index, Math.round(slider.value))
        }
    }

    StyledRect {
        id: presetsBg

        color: Colors.colLayer2
        height: 85
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        ListView {
            anchors {
                fill: parent
                leftMargin: Padding.large
                rightMargin: Padding.large
            }
            orientation: Qt.Horizontal
            spacing: Padding.large
            clip: true
            model: store.eqPresets

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
        id: bandRoot

        required property string bandName
        required property var modelData
        required property int index

        property alias slider: slider

        radius: Rounding.verylarge
        height: 72
        color: Colors.colLayer2

        RowLayout {
            anchors {
                fill: parent
                leftMargin: Padding.huge
                rightMargin: Padding.huge
            }

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
