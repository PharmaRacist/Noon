import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

ColumnLayout {
    spacing: Padding.large
    Spacer {}

    OptionCombo {
        title: "Hits Mode"
        key: BeatsService.daemonOptions.hits.recommendationsMode
        values: ["tracks", "playlists", "both"]
    }

    OptionSpin {
        title: "Search Limit"
        spin.value: Mem.states.services.beats.searchLimit
        spin.from: 16
        spin.to: 1000
        spin.onValueChanged: if (spin.value > 0) {
            Mem.states.services.beats.searchLimit = spin.value;
        }
    }

    OptionSwitch {
        title: "Shuffle Hits"
        button.checked: Mem.states.services.beats.shuffleHits
        button.onCheckedChanged: () => Mem.states.services.beats.shuffleHits = button.checked
    }

    OptionSwitch {
        title: "Normalize Audio"
        button.checked: BeatsService.daemonOptions.players.main.volumeNormalization.enabled
        button.onCheckedChanged: () => BeatsService.daemonOptions.players.main.volumeNormalization.enabled = button.checked
    }

    component OptionCombo: RowLayout {
        property alias values: combo.model
        property alias title: title.text
        property var key
        property alias combo: combo
        StyledText {
            id: title
            color: Colors.colOnLayer3
            font.pixelSize: Fonts.sizes.small
            Layout.fillWidth: true
        }
        StyledComboBox {
            id: combo
            Layout.maximumWidth: 140
            implicitHeight: 40
            currentIndex: values.indexOf(key)
            onActivated: index => {
                if (index >= 0 && index < values.length && key !== values[index]) {
                    key = values[index];
                    BeatsHitsService.refresh();
                }
            }
        }
    }

    component OptionSwitch: RowLayout {
        property alias title: title.text
        property var key
        property alias button: button
        StyledText {
            id: title
            color: Colors.colOnLayer3
            font.pixelSize: Fonts.sizes.small
            Layout.fillWidth: true
        }
        StyledSwitch {
            id: button
        }
    }
    component OptionSpin: RowLayout {
        property alias title: title.text
        property var key
        property alias spin: spin
        StyledText {
            id: title
            color: Colors.colOnLayer3
            font.pixelSize: Fonts.sizes.small
            Layout.fillWidth: true
        }
        StyledSpinBox {
            id: spin
        }
    }
}
