import QtQuick
import qs.common

NumberAnimation {
    easing.type: Easing.BezierSpline
    duration: Animations.durations.expressiveFastSpatial
    easing.bezierCurve: Animations.curves.expressiveEffects
}
