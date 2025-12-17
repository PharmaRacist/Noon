import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

RippleButton {
    id: root
    required property ListView target

    anchors {
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
        bottomMargin: 10
    }

    opacity: !target.atYEnd ? 1 : 0
    scale: !target.atYEnd ? 1 : 0.7
    visible: opacity > 0
    Behavior on opacity {
        FAnim {}
    }
    Behavior on scale {
        Anim {}
    }

    implicitWidth: contentItem.implicitWidth + 8 * 2
    implicitHeight: contentItem.implicitHeight + 4 * 2

    colBackground: Colors.colSecondary
    colBackgroundHover: Colors.colSecondaryHover
    colRipple: Colors.colSecondaryActive
    buttonRadius: Rounding.verysmall

    downAction: () => {
        target.positionViewAtEnd();
    }

    contentItem: Row {
        id: contentItem
        spacing: 4
        MaterialSymbol {
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
