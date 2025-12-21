import QtQuick
import QtQuick.Controls
import Quickshell
import qs.modules.common.widgets
import qs.services

QuickToggleButton {
    id: root

    showButtonName: false
    toggled: !PowerService.isBattery
    buttonIcon: PowerService.icon
    onClicked: PowerService.toggleMode()

    StyledToolTip {
        content: qsTr("Toggle Power Profile")
    }
}
