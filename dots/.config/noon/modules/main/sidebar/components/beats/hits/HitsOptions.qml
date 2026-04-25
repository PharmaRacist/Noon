import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

ColumnLayout {
    spacing: Padding.large
    Spacer {}
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
