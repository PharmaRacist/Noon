import QtQuick
import Quickshell
pragma Singleton

Singleton {
    property QtObject luna
    property QtObject lunaSilver
    property QtObject lunaBeige
    property QtObject colors: luna

    luna: QtObject {
        readonly property color primary: "#758252"
        readonly property color primaryContainer: "#2E61D6"
        readonly property color primaryBorder: "#5297FF"
        readonly property color secondary: "#208EE8"
        readonly property color secondaryBorder: "#2AA2FB"
        readonly property color tertiary: "#19911D"
        readonly property color tertiaryBorder: "#84BD7E"
        readonly property color quatrenary: "#D3E5FB"
        readonly property color quatrenaryContainer: "#D3E5FB"
        readonly property color quatrenaryBorder: "#A7B8D4"
        readonly property color quatrenarySeparator: "#A5B6C9"
        readonly property color critical: "#EC7E6D"
        readonly property color warning: "#DAA60D"
        readonly property color shadows: "#75000000"
    }

}
