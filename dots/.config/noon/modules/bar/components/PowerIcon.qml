import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services

MaterialShapeWrappedMaterialSymbol {
    text: PowerService.icon
    shape: PowerService.isBattery ? MaterialShape.Cookie6Sided : MaterialShape.Cookie7Sided
    fill: 1
    color: PowerService.isBattery ? Colors.colLayer2 : Colors.colSecondaryActive
    colSymbol: PowerService.isBattery ? Colors.colOnLayer2 : Colors.colSecondary
    iconSize: parent.width / 2.4

    MouseArea {
        anchors.fill: parent
        onClicked: () => {
            PowerService.toggleMode();
            console.log("pressed");
        }
    }
}
