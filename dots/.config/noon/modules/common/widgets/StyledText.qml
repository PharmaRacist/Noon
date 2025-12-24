import QtQuick
import QtQuick.Layouts
import qs.modules.common

Text {
    id: root

    property bool animateChange: false
    property real animationDistanceX: 0
    property real animationDistanceY: 6

    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    color: Colors.m3.m3onBackground ?? "black"
    linkColor: Colors.m3.m3primary
    Component.onCompleted: {
        textAnimationBehavior.originalX = root.x;
        textAnimationBehavior.originalY = root.y;
    }

    Behavior on text {
        id: textAnimationBehavior

        property real originalX: root.x
        property real originalY: root.y

        enabled: root.animateChange

        SequentialAnimation {
            alwaysRunToEnd: true

            ParallelAnimation {
                FAnim {
                    target: root
                    property: "x"
                    to: textAnimationBehavior.originalX - root.animationDistanceX
                    easing.type: Easing.InSine
                }

                FAnim {
                    target: root
                    property: "y"
                    to: textAnimationBehavior.originalY - root.animationDistanceY
                    easing.type: Easing.InSine
                }

                FAnim {
                    target: root
                    property: "opacity"
                    to: 0
                    easing.type: Easing.InSine
                }

            }
            // Tie the text update to this point (we don't want it to happen during the first slide+fade)

            PropertyAction {
            }

            PropertyAction {
                target: root
                property: "x"
                value: textAnimationBehavior.originalX + root.animationDistanceX
            }

            PropertyAction {
                target: root
                property: "y"
                value: textAnimationBehavior.originalY + root.animationDistanceY
            }

            ParallelAnimation {
                FAnim {
                    target: root
                    property: "x"
                    to: textAnimationBehavior.originalX
                    easing.type: Easing.OutSine
                }

                FAnim {
                    target: root
                    property: "y"
                    to: textAnimationBehavior.originalY
                    easing.type: Easing.OutSine
                }

                FAnim {
                    target: root
                    property: "opacity"
                    to: 1
                    easing.type: Easing.OutSine
                }

            }

        }

    }

}
