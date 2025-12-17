import QtQuick
import qs.modules.common

NumberAnimation {
    easing.type: Easing.BezierSpline
    duration: Animations.durations.small
    easing.bezierCurve: Animations.curves.expressiveFastSpatial
}
