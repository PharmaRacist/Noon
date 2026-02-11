import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.store

GroupButton {
    id: root

    property string buttonIcon
    property string buttonName
    property string buttonSubtext

    property bool showButtonName: buttonName.length > 0
    property bool hasDialog: false

    signal requestDialog
    Layout.fillWidth: showButtonName
    Layout.fillHeight: false
    baseWidth: !showButtonName ? baseHeight : (SidebarData.sizePresets.quarter / 2.5) - Padding.huge
    baseHeight: !showButtonName ? 54 : 62
    clip: true
    clickedWidth: implicitWidth
    toggled: false
    buttonRadius: !toggled ? Rounding.huge : Rounding.full
    buttonRadiusPressed: toggled ? Rounding.huge : Rounding.full
    color: Colors.colLayer2

    altAction: () => requestDialog()

    StyledRect {
        id: sideRect
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: Padding.verysmall + 1
        }
        implicitWidth: height
        color: {
            if (root.toggled && root.hovered)
                return Colors.colPrimaryHover;
            else if (root.toggled)
                return Colors.colPrimary;
            else if (!root.toggled && !root.hovered)
                return !root.showButtonName ? "transparent" : Colors.colLayer3;
            else if (!root.toggled && root.hovered)
                return Colors.colLayer3Hover;
            else
                return Colors.colLayer3;
        }
        radius: root.buttonRadius
        Symbol {
            anchors.centerIn: parent
            fill: root.toggled
            text: root.buttonIcon
            font.pixelSize: 20
            color: root.toggled ? Colors.colOnPrimary : Colors.colOnLayer3
        }
    }

    Behavior on buttonRadius {
        Anim {}
    }

    ColumnLayout {
        anchors {
            verticalCenter: parent.verticalCenter
            left: sideRect.right
            leftMargin: Padding.large
            right: parent.right
            rightMargin: Padding.large
        }
        spacing: Padding.tiny

        StyledText {
            visible: root.showButtonName
            Layout.fillWidth: true
            Layout.rightMargin: Padding.massive
            text: root.buttonName.charAt(0).toUpperCase() + root.buttonName.slice(1)
            horizontalAlignment: Text.AlignHLeft
            truncate: true
            font.pixelSize: Fonts.sizes.normal
            color: Colors.colOnLayer3
        }

        StyledText {
            visible: root.buttonSubtext.length > 0
            Layout.fillWidth: true
            Layout.rightMargin: Padding.massive
            text: root.buttonSubtext.charAt(0).toUpperCase() + root.buttonSubtext.slice(1)
            horizontalAlignment: Text.AlignHLeft
            truncate: true
            font.pixelSize: Fonts.sizes.small
            color: Colors.colSubtext
        }
    }
}
