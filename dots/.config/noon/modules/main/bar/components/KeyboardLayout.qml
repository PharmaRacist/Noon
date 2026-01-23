import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

BarGroup {
    id: root
    vertical: verticalMode
    property bool verticalMode: true
    property real commonIconSize: Fonts.sizes.verylarge
    property color commonIconColor: Colors.colOnLayer1
    readonly property string currentLayout: HyprlandService.keyboardLayoutShortName
    Layout.preferredHeight: width

    StyledText {
        anchors.centerIn: parent
        text: currentLayout
        color: commonIconColor
        font.pixelSize: Fonts.sizes.small
        animateChange: true
        font.variableAxes: Fonts.variableAxes.title
    }
    MouseArea {
        anchors.fill: parent
        onClicked: HyprlandService.switchKeyboardLayout()
    }
}
