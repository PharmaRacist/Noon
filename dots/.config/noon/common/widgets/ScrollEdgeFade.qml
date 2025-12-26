import QtQuick
import qs.common
import qs.common.functions

Item {
    id: root

    required property Item target
    property real fadeSize: Colors.m3.darkmode ? 40 : 20
    property color color: ColorUtils.transparentize(Colors.colShadow, Colors.m3.darkmode ? 0 : 0.7)
    property bool vertical: true

    z: 99
    anchors.fill: target

    EndGradient {
        shown: !(root.vertical ? root.target.atYBeginning : root.target.atXBeginning)

        anchors {
            top: parent.top
            left: parent.left
            right: vertical ? parent.right : undefined
            bottom: vertical ? undefined : parent.bottom
        }

    }

    EndGradient {
        shown: !(root.vertical ? root.target.atYEnd : root.target.atXEnd)
        rotation: 180

        anchors {
            bottom: parent.bottom
            right: parent.right
            left: vertical ? parent.left : undefined
            top: vertical ? undefined : parent.top
        }

    }

    component EndGradient: Rectangle {
        required property bool shown

        height: vertical ? root.fadeSize : parent.height
        width: vertical ? parent.width : root.fadeSize
        opacity: shown ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            Anim {
            }

        }

        gradient: Gradient {
            orientation: root.vertical ? Gradient.Vertical : Gradient.Horizontal

            GradientStop {
                position: 0
                color: root.color
            }

            GradientStop {
                position: 1
                color: ColorUtils.transparentize(root.color)
            }

        }

    }

}
