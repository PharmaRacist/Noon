import QtQuick
import qs.common

NumberAnimation {
    easing.type: Easing.BezierSpline
    duration: Animations.durations.small
    easing.bezierCurve: Animations.curves.expressiveFastSpatial
}
