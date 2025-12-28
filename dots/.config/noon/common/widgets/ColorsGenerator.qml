import QtQuick
import Quickshell
import qs.common
import qs.common.functions

Item {
    id: root
    property color keyColor: "white"
    property bool active: false
    property QtObject colors: active ? template : Colors

    property QtObject template: QtObject {
        id: i

        readonly property color darkerKey: Qt.darker(root.keyColor, 2)
        readonly property color slightlyDarkerKey: Qt.darker(root.keyColor, 1.2)

        property color colScrim: ColorUtils.transparentize(Colors.colScrim, darkerKey, 0.25)
        property color colSubtext: ColorUtils.colorWithLightness(i.colOnLayer1, 0.45)
        property color colTint: ColorUtils.transparentize(Colors.colSecondaryContainerActive, darkerKey, 0.25)

        property color colLayer0: ColorUtils.mix(Colors.colLayer0, darkerKey, 0.1)
        property color colOnLayer0: ColorUtils.mix(Colors.colOnLayer0, root.keyColor, 0.8)
        property color colLayer0Hover: ColorUtils.mix(colLayer0, colOnLayer0, 0.9)
        property color colLayer0Active: ColorUtils.mix(colLayer0, colOnLayer0, 0.8)
        property color colLayer0Border: ColorUtils.mix(Colors.m3.m3outlineVariant, colLayer0, 0.4)

        property color colLayer1: ColorUtils.mix(Colors.colLayer1, slightlyDarkerKey, 0.35)
        property color colOnLayer1: ColorUtils.mix(Colors.colOnLayer1, root.keyColor, 0.5)
        property color colOnLayer1Inactive: ColorUtils.mix(colOnLayer1, colLayer1, 0.45)
        property color colLayer1Hover: ColorUtils.mix(Colors.colLayer1Hover, root.keyColor, 0.4)
        property color colLayer1Active: ColorUtils.mix(Colors.colLayer1Active, root.keyColor, 0.5)

        property color colLayer2: ColorUtils.mix(Colors.colLayer2, root.keyColor, 0.34)
        property color colOnLayer2: ColorUtils.mix(Colors.colOnLayer2, root.keyColor, 0.45)
        property color colOnLayer2Disabled: ColorUtils.mix(colOnLayer2, Colors.m3.m3background, 0.4)
        property color colLayer2Hover: ColorUtils.mix(colLayer2, colOnLayer2, 0.9)
        property color colLayer2Active: ColorUtils.mix(colLayer2, colOnLayer2, 0.8)
        property color colLayer2Disabled: ColorUtils.mix(colLayer2, Colors.m3.m3background, 0.8)

        property color colLayer3: ColorUtils.mix(Colors.colLayer3, root.keyColor, 0.3)
        property color colOnLayer3: ColorUtils.mix(Colors.colOnLayer3, root.keyColor, 0.45)
        property color colLayer3Hover: ColorUtils.mix(colLayer3, colOnLayer3, 0.9)
        property color colLayer3Active: ColorUtils.mix(colLayer3, colOnLayer3, 0.8)

        property color colLayer4: ColorUtils.mix(Colors.colLayer4, root.keyColor, 0.25)
        property color colOnLayer4: ColorUtils.mix(Colors.colOnLayer4, root.keyColor, 0.45)
        property color colLayer4Hover: ColorUtils.mix(colLayer4, colOnLayer4, 0.9)
        property color colLayer4Active: ColorUtils.mix(colLayer4, colOnLayer4, 0.8)

        property color colPrimary: ColorUtils.mix(ColorUtils.adaptToAccent(Colors.colPrimary, root.keyColor), root.keyColor, 1)
        property color colOnPrimary: ColorUtils.mix(ColorUtils.adaptToAccent(Colors.m3.m3onPrimary, root.keyColor), root.keyColor, 0.7)
        property color colPrimaryHover: ColorUtils.mix(ColorUtils.adaptToAccent(Colors.colPrimaryHover, root.keyColor), root.keyColor, 1)
        property color colPrimaryActive: ColorUtils.mix(colPrimary, colLayer1Active, 0.7)
        property color colPrimaryContainer: ColorUtils.mix(Colors.colPrimaryContainer, root.keyColor, 0.3)
        property color colPrimaryContainerHover: ColorUtils.mix(colPrimaryContainer, colLayer1Hover, 0.7)
        property color colPrimaryContainerActive: ColorUtils.mix(colPrimaryContainer, colLayer1Active, 0.6)
        property color colOnPrimaryContainer: ColorUtils.mix(Colors.colOnPrimaryContainer, root.keyColor, 0.6)

        property color colSecondary: ColorUtils.mix(Colors.m3.m3secondary, root.keyColor, 0.2)
        property color colOnSecondary: ColorUtils.mix(Colors.m3.m3onSecondary, root.keyColor, 0.95)
        property color colSecondaryHover: ColorUtils.mix(Colors.m3.m3secondary, root.keyColor, 0.76)
        property color colSecondaryActive: ColorUtils.mix(colSecondary, colLayer1Active, 0.4)
        property color colSecondaryContainer: Qt.darker(colSecondary, 1.4)
        property color colSecondaryContainerHover: ColorUtils.mix(Colors.colSecondaryContainerHover, root.keyColor, 0.5)
        property color colSecondaryContainerActive: ColorUtils.mix(Colors.colSecondaryContainerActive, root.keyColor, 0.5)
        property color colOnSecondaryContainer: ColorUtils.mix(Colors.m3.m3onSurface, root.keyColor, 0.6)

        property color colOnSurface: ColorUtils.mix(Colors.colOnSurface, root.keyColor, 0.5)
        property color colOnSurfaceVariant: ColorUtils.mix(Colors.colOnSurfaceVariant, root.keyColor, 0.5)
        property color colOnSurfaceDisabled: ColorUtils.mix(colOnSurface, Colors.m3.m3background, 0.4)
        property color colOnSurfaceLowEmphasis: ColorUtils.mix(colOnSurface, colOnSurfaceVariant, 0.6)
        property color colInverseSurface: ColorUtils.mix(Colors.colInverseSurface, root.keyColor, 0.3)
        property color colInverseOnSurface: ColorUtils.mix(Colors.colInverseOnSurface, root.keyColor, 0.5)

        property color colTertiary: ColorUtils.mix(Colors.colTertiary, root.keyColor, 0.3)
        property color colTertiaryContainer: ColorUtils.mix(Colors.colTertiaryContainer, root.keyColor, 0.3)
        property color colTertiaryHover: ColorUtils.mix(colTertiary, colLayer1Hover, 0.85)
        property color colTertiaryActive: ColorUtils.mix(colTertiary, colLayer1Active, 0.4)
        property color colTertiaryContainerHover: ColorUtils.mix(colTertiaryContainer, colLayer1Hover, 0.7)
        property color colTertiaryContainerActive: ColorUtils.mix(colTertiaryContainer, colLayer1Active, 0.6)
        property color colOnTertiary: ColorUtils.mix(Colors.m3.m3onTertiary, root.keyColor, 0.6)
        property color colOnTertiaryContainer: ColorUtils.mix(Colors.m3.m3onTertiaryContainer, root.keyColor, 0.6)

        property color colSurfaceContainerLow: ColorUtils.mix(Colors.colSurfaceContainerLow, root.keyColor, 0.2)
        property color colSurfaceContainer: ColorUtils.mix(Colors.colSurfaceContainer, root.keyColor, 0.25)
        property color colSurfaceContainerHigh: ColorUtils.mix(Colors.colSurfaceContainerHigh, root.keyColor, 0.3)
        property color colSurfaceContainerHighest: ColorUtils.mix(Colors.colSurfaceContainerHighest, root.keyColor, 0.35)
        property color colSurfaceContainerHighestHover: ColorUtils.mix(colSurfaceContainerHighest, colOnSurface, 0.95)
        property color colSurfaceContainerHighestActive: ColorUtils.mix(colSurfaceContainerHighest, colOnSurface, 0.85)

        property color colError: ColorUtils.mix(Colors.colError, root.keyColor, 0.3)
        property color colOnError: ColorUtils.mix(Colors.colOnError, root.keyColor, 0.5)
        property color colErrorHover: ColorUtils.mix(colError, colLayer1Hover, 0.85)
        property color colErrorActive: ColorUtils.mix(colError, colLayer1Active, 0.7)
        property color colErrorContainer: ColorUtils.mix(Colors.colErrorContainer, root.keyColor, 0.3)
        property color colErrorContainerHover: ColorUtils.mix(colErrorContainer, Colors.m3.m3onErrorContainer, 0.9)
        property color colErrorContainerActive: ColorUtils.mix(colErrorContainer, Colors.m3.m3onErrorContainer, 0.7)
        property color colOnErrorContainer: ColorUtils.mix(Colors.colOnErrorContainer, root.keyColor, 0.6)

        property color colOutline: ColorUtils.mix(Colors.colOutline, root.keyColor, 0.3)
        property color colOutlineVariant: ColorUtils.mix(Colors.colOutlineVariant, root.keyColor, 0.3)
        property color colTooltip: ColorUtils.mix(Colors.colTooltip, root.keyColor, 0.2)
        property color colOnTooltip: Colors.colOnTooltip
        property color colShadow: ColorUtils.mix(Colors.colShadow, darkerKey, 0.3)
    }
}
