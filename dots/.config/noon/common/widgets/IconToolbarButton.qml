import QtQuick
import QtQuick.Layouts
import qs.common

ToolbarButton {
    id: iconBtn

    property color colText: toggled ? Colors.colOnSecondaryContainer : Colors.colOnSurfaceVariant

    implicitWidth: height
    colBackgroundToggled: Colors.colSecondaryContainer
    colBackgroundToggledHover: Colors.colSecondaryContainerHover
    colRippleToggled: Colors.colSecondaryContainerActive

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
