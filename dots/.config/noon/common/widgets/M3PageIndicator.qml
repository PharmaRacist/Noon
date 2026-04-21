import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.common

RowLayout {
    id: root

    property int currentIndex: 0
    property int count: 0
    property double itemSize: 12
    property double activeItemSize: 18
    spacing: Padding.small

    readonly property var shapes: [MaterialShape.Shape.PuffyDiamond, MaterialShape.Shape.Cookie7Sided, MaterialShape.Shape.Clover4Leaf, MaterialShape.Shape.Gem, MaterialShape.Shape.Slanted, MaterialShape.Shape.PixelTriangle, MaterialShape.Shape.Cookie9Sided, MaterialShape.Shape.Oval, MaterialShape.Shape.Heart, MaterialShape.Shape.SoftBurst, MaterialShape.Shape.Cookie12Sided, MaterialShape.Shape.Arch, MaterialShape.Shape.Pill, MaterialShape.Shape.Sunny, MaterialShape.Shape.Ghostish, MaterialShape.Shape.Clover8Leaf, MaterialShape.Shape.Square, MaterialShape.Shape.Cookie4Sided, MaterialShape.Shape.Pentagon, MaterialShape.Shape.SoftBoom, MaterialShape.Shape.Triangle, MaterialShape.Shape.Boom, MaterialShape.Shape.Flower, MaterialShape.Shape.Diamond, MaterialShape.Shape.Puffy, MaterialShape.Shape.PixelCircle, MaterialShape.Shape.ClamShell, MaterialShape.Shape.VerySunny, MaterialShape.Shape.Bun, MaterialShape.Shape.Cookie6Sided, MaterialShape.Shape.SemiCircle, MaterialShape.Shape.Arrow, MaterialShape.Shape.Fan, MaterialShape.Shape.Burst]
    Repeater {
        model: root.count
        MaterialShape {
            required property int index
            Layout.alignment: Qt.AlignVCenter
            shape: root.currentIndex !== index ? MaterialShape.Shape.Circle : root.shapes[index]
            implicitSize: root.currentIndex === index ? root.activeItemSize : root.itemSize
            opacity: root.currentIndex === index ? 1.0 : 0.4
            color: root.currentIndex === index ? Colors.colPrimary : Colors.colSecondary

            Behavior on implicitSize {
                Anim {}
            }

            Behavior on opacity {
                Anim {}
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.currentIndex = index
            }
        }
    }
}
