import QtQuick
import QtQuick.Shapes
import qs.common

Item {
    id: root
    property int size: Rounding.verylarge
    property color color: parent?.color ?? Colors.colLayer0

    property QtObject cornerEnum: QtObject {
        property int topLeft: 0
        property int topRight: 1
        property int bottomLeft: 2
        property int bottomRight: 3
    }
    property int corner: cornerEnum.topLeft // Default to TopLeft

    // Add a revision property that changes when corner changes
    property int shapeRevision: 0

    onCornerChanged: {
        shapeRevision++;  // Force shape to update
    }

    width: size
    height: size

    Shape {
        anchors.fill: parent
        antialiasing: true
        preferredRendererType: Shape.CurveRenderer

        // Force the shape to depend on shapeRevision to trigger redraws
        property int revision: root.shapeRevision

        ShapePath {
            strokeWidth: 0
            fillColor: root.color

            startX: {
                // Reference shapeRevision to ensure binding updates
                root.shapeRevision;
                switch (root.corner) {
                case root.cornerEnum.topLeft:
                    return 0;
                case root.cornerEnum.topRight:
                    return root.size;
                case root.cornerEnum.bottomLeft:
                    return 0;
                case root.cornerEnum.bottomRight:
                    return root.size;
                default:
                    return 0;
                }
            }

            startY: {
                // Reference shapeRevision to ensure binding updates
                root.shapeRevision;
                switch (root.corner) {
                case root.cornerEnum.topLeft:
                    return 0;
                case root.cornerEnum.topRight:
                    return 0;
                case root.cornerEnum.bottomLeft:
                    return root.size;
                case root.cornerEnum.bottomRight:
                    return root.size;
                default:
                    return 0;
                }
            }

            PathAngleArc {
                moveToStart: false
                centerX: {
                    // Reference shapeRevision to ensure binding updates
                    root.shapeRevision;
                    switch (root.corner) {
                    case root.cornerEnum.topLeft:
                        return root.size;
                    case root.cornerEnum.topRight:
                        return 0;
                    case root.cornerEnum.bottomLeft:
                        return root.size;
                    case root.cornerEnum.bottomRight:
                        return 0;
                    }
                }
                centerY: {
                    // Reference shapeRevision to ensure binding updates
                    root.shapeRevision;
                    switch (root.corner) {
                    case root.cornerEnum.topLeft:
                        return root.size;
                    case root.cornerEnum.topRight:
                        return root.size;
                    case root.cornerEnum.bottomLeft:
                        return 0;
                    case root.cornerEnum.bottomRight:
                        return 0;
                    }
                }
                radiusX: root.size
                radiusY: root.size
                startAngle: {
                    // Reference shapeRevision to ensure binding updates
                    root.shapeRevision;
                    switch (root.corner) {
                    case root.cornerEnum.topLeft:
                        return 180;
                    case root.cornerEnum.topRight:
                        return 270;
                    case root.cornerEnum.bottomLeft:
                        return 90;
                    case root.cornerEnum.bottomRight:
                        return 0;
                    }
                }
                sweepAngle: 90
            }

            PathLine {
                x: {
                    // Reference shapeRevision to ensure binding updates
                    root.shapeRevision;
                    switch (root.corner) {
                    case root.cornerEnum.topLeft:
                        return 0;
                    case root.cornerEnum.topRight:
                        return root.size;
                    case root.cornerEnum.bottomLeft:
                        return 0;
                    case root.cornerEnum.bottomRight:
                        return root.size;
                    default:
                        return 0;
                    }
                }
                y: {
                    // Reference shapeRevision to ensure binding updates
                    root.shapeRevision;
                    switch (root.corner) {
                    case root.cornerEnum.topLeft:
                        return 0;
                    case root.cornerEnum.topRight:
                        return 0;
                    case root.cornerEnum.bottomLeft:
                        return root.size;
                    case root.cornerEnum.bottomRight:
                        return root.size;
                    default:
                        return 0;
                    }
                }
            }
        }
    }
}
