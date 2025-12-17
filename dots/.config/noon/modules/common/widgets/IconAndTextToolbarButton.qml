import QtQuick
import QtQuick.Layouts
import qs.modules.common

ToolbarButton {
    id: iconBtn
    required property string iconText

    colBackgroundToggled: Colors.colSecondaryContainer
    colBackgroundToggledHover: Colors.colSecondaryContainerHover
    colRippleToggled: Colors.colSecondaryContainerActive
    property color colText: toggled ? Colors.colOnSecondaryContainer : Colors.colOnSurfaceVariant

    contentItem: Row {
        anchors.centerIn: parent
        spacing: 4

        MaterialSymbol {
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            iconSize: 22
            text: iconBtn.iconText
            color: iconBtn.colText
        }
        StyledText {
            visible: iconBtn.iconText.length > 0 && iconBtn.text.length > 0
            anchors.verticalCenter: parent.verticalCenter
            color: iconBtn.colText
            text: iconBtn.text
        }
    }
}
