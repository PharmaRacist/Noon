import QtQuick
import QtQuick.Layouts
import qs.common

ToolbarButton {
    id: iconBtn

    required property string iconText
    property color colText: toggled ? Colors.colOnSecondaryContainer : Colors.colOnSurfaceVariant

    colBackgroundToggled: Colors.colSecondaryContainer
    colBackgroundToggledHover: Colors.colSecondaryContainerHover
    colRippleToggled: Colors.colSecondaryContainerActive

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
