import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

RippleButton {
    id: root

    required property ListView target

    opacity: !target.atYEnd ? 1 : 0
    scale: !target.atYEnd ? 1 : 0.7
    visible: opacity > 0
    implicitWidth: contentItem.implicitWidth + 8 * 2
    implicitHeight: contentItem.implicitHeight + 4 * 2
    colBackground: Colors.colSecondary
    colBackgroundHover: Colors.colSecondaryHover
    colRipple: Colors.colSecondaryActive
    buttonRadius: Rounding.verysmall
    downAction: () => {
        target.positionViewAtEnd();
    }

    anchors {
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
        bottomMargin: 10
    }

    Behavior on opacity {
        Anim {
        }

    }

    Behavior on scale {
        Anim {
        }

    }

    contentItem: Row {
        id: contentItem

        spacing: 4

        Symbol {
            anchors.verticalCenter: parent.verticalCenter
            text: "arrow_downward"
            font.pixelSize: Fonts.sizes.verylarge
            color: Colors.colOnSecondary
            verticalAlignment: Text.AlignVCenter
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Scroll to Bottom")
            font.pixelSize: Fonts.sizes.small
            color: Colors.colOnSecondary
            verticalAlignment: Text.AlignVCenter
        }

    }

}
