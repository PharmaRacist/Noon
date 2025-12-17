import QtQuick
import QtQuick.Layouts
import qs.modules.common

ToolbarButton {
    id: iconBtn
    implicitWidth: height

    colBackgroundToggled: Colors.colSecondaryContainer
    colBackgroundToggledHover: Colors.colSecondaryContainerHover
    colRippleToggled: Colors.colSecondaryContainerActive
    property color colText: toggled ? Colors.colOnSecondaryContainer : Colors.colOnSurfaceVariant

    contentItem: MaterialSymbol {
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        iconSize: 22
        text: iconBtn.text
        color: iconBtn.colText
        animateChange: true
    }
}
