import QtQuick
import Quickshell
import qs.modules.common

QtObject {
    property QtObject family
    property QtObject sizes
    property QtObject variableAxes

    family: QtObject {
        property string main: Mem.options.appearance.fonts.main ?? "Google Sans Flex"
        property string monospace: "Iosevka"
        property string variable: "Google Sans Flex"
        property string iconMaterial: "Material Symbols Rounded"
    }
    sizes: QtObject {
        property real scale: Mem.options.appearance.fonts.scale ?? 1
        property int verysmall: 12 * scale
        property int small: 14 * scale
        property int normal: 16 * scale
        property int large: 18 * scale
        property int verylarge: 20 * scale
        property int huge: 22 * scale
        property int veryhuge: 24 * scale
        property int title: 46 * scale
        property int subTitle: 32 * scale
    }
    variableAxes: QtObject {
        property var main: ({
                "wght": 450,
                "wdth": 100
            })
        property var lyrics: ({
                "wght": 600,
                "wdth": 100
            })
        property var numbers: ({
                "wght": 550,
                "wdth": 100
            })
        property var title: ({
                "wght": 550
            })
        property var display: ({
                "wght": Mem.states.fonts.variableAxes.display.wght,
                "wdth": Mem.states.fonts.variableAxes.display.wdth,
                "ital": Mem.states.fonts.variableAxes.display.ital,
                "slnt": Mem.states.fonts.variableAxes.display.slnt,
                "opsz": Mem.states.fonts.variableAxes.display.opsz
            })
    }
}
