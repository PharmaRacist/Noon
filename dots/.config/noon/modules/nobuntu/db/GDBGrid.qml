import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services
import "../common"
import qs.modules.main.sidebar.components.notifs.quickToggles

GridLayout {
    Layout.fillHeight: true
    Layout.fillWidth: true
    Layout.margins: Padding.large
    columns: 2
    rowSpacing: Padding.normal
    columnSpacing: Padding.large

    NetworkToggle {}
    BluetoothToggle {}
    NightLightToggle {}
    AppearanceToggle {}
}
