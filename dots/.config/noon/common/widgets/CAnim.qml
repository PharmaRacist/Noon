import QtQuick
import qs.common

ColorAnimation {
    easing.type: Easing.BezierSpline
    duration: Animations.durations.expressiveFastSpatial
    easing.bezierCurve: Animations.curves.expressiveEffects
}
