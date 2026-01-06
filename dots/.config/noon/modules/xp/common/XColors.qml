pragma Singleton
import QtQuick
import Quickshell
import qs.common.functions

Singleton {
    property QtObject luna
    property QtObject lunaSilver
    property QtObject lunaBeige
    property QtObject colors: luna

    luna: QtObject {
        readonly property real dimintensity: 1.2
        readonly property real lightintensity: 1.2
        readonly property color colPrimary: "#2C70CF"
        readonly property color colOnPrimary: "#FFFFFF"
        readonly property color colPrimaryContainer: "#225DDB"
        readonly property color colPrimaryBorder: "#074491"
        readonly property color colPrimaryBorderDim: Qt.darker(colPrimaryBorder, dimintensity)
        readonly property color colSecondary: "#0C92ED"
        readonly property color colSecondaryDim: Qt.darker(colSecondary, dimintensity)
        readonly property color colSecondaryHover: Qt.lighter(colSecondary, lightintensity)
        readonly property color colOnSecondary: "#A6FDFF"
        readonly property color colSecondaryBorder: "#1FAAE9"
        readonly property color colTertiary: "#2D812D" // Start Button Bg
        readonly property color colTertiaryBorder: "#84BD7E"
        readonly property color colQuaternary: "#D3E5FB"
        readonly property color colQuaternaryContainer: "#D3E5FB"
        readonly property color colQuaternaryBorder: "#A7B8D4"
        readonly property color colQuaternarySeparator: "#A5B6C9"
        readonly property color colCritical: "#F13F1C"
        readonly property color colOnCritical: "#FFF8F5"
        readonly property color colCriticalHover: Qt.lighter(colCritical, lightintensity)
        readonly property color colCriticalBorder: ColorUtils.transparentize(colCritical, 0.45)
        readonly property color colWarning: "#F2AF00"
        readonly property color colOnWarning: "#FFFCF8"
        readonly property color colWarningHover: Qt.lighter(colWarning, lightintensity)
        readonly property color colWarningBorder: ColorUtils.transparentize(colWarning, 0.45)
        readonly property color colShadows: "#75000000"
    }
}
