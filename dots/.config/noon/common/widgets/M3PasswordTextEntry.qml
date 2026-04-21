import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.common
import qs.common.widgets

/*
    Simple Shape Password Entry
*/
StyledTextField {
    id: root
    property color colBackground: Colors.colLayer2
    property color colText: Colors.colOnLayer2
    property color colSelectionColor: Colors.colSecondaryContainer
    property color colSelectionText: Colors.colOnSecondaryContainer
    property int radius: Rounding.verylarge
    property bool passwordMode: false
    color: !passwordMode ? "transparent" : colText
    objectName: "searchInput"
    placeholderText: "Enter Your Password .. "
    selectionColor: "transparent"
    selectedTextColor: "transparent"
    selectByMouse: true
    font.family: Fonts.family.variable
    clip: true
    Keys.onEscapePressed: focus = false
    background: StyledRect {
        color: root.colBackground
        radius: root.radius
    }
    RowLayout {
        id: shapesRow
        z: 999
        anchors.centerIn: parent
        spacing: Padding.small
        readonly property int count: root.text.length
        readonly property var shapes: [MaterialShape.Shape.PuffyDiamond, MaterialShape.Shape.Cookie7Sided, MaterialShape.Shape.Clover4Leaf, MaterialShape.Shape.Gem, MaterialShape.Shape.Slanted, MaterialShape.Shape.PixelTriangle, MaterialShape.Shape.Cookie9Sided, MaterialShape.Shape.Oval, MaterialShape.Shape.Heart, MaterialShape.Shape.SoftBurst, MaterialShape.Shape.Cookie12Sided, MaterialShape.Shape.Arch, MaterialShape.Shape.Pill, MaterialShape.Shape.Sunny, MaterialShape.Shape.Ghostish, MaterialShape.Shape.Clover8Leaf, MaterialShape.Shape.Square, MaterialShape.Shape.Cookie4Sided, MaterialShape.Shape.Pentagon, MaterialShape.Shape.SoftBoom, MaterialShape.Shape.Triangle, MaterialShape.Shape.Boom, MaterialShape.Shape.Flower, MaterialShape.Shape.Diamond, MaterialShape.Shape.Puffy, MaterialShape.Shape.PixelCircle, MaterialShape.Shape.ClamShell, MaterialShape.Shape.VerySunny, MaterialShape.Shape.Bun, MaterialShape.Shape.Cookie6Sided, MaterialShape.Shape.SemiCircle, MaterialShape.Shape.Arrow, MaterialShape.Shape.Fan, MaterialShape.Shape.Burst]

        Repeater {
            id: shapeRepeater
            model: root.text.length
            delegate: MaterialShape {
                required property var modelData
                required property int index
                Layout.alignment: Qt.AlignVCenter
                shape: shapesRow.shapes[index]
                implicitSize: (index === shapesRow?.count ?? false) ? 32 : 18
                color: Colors.colPrimary
                Behavior on implicitSize {
                    Anim {
                        duration: 1000
                    }
                }
            }
        }
    }
}
