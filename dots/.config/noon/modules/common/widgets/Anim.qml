import QtQuick
import qs.modules.common

NumberAnimation {
    easing.type: Easing.BezierSpline
    duration: Animations.durations.expressiveFastSpatial
    easing.bezierCurve: Animations.curves.expressiveDefaultSpatial
}
