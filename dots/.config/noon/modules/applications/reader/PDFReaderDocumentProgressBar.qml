import QtQuick
import qs.common
import qs.common.widgets

Item {
    id: root
    required property var pdf
    required property var pdf_view
    anchors {
        bottom: parent.bottom
        right: parent.right
        left: parent.left
        margins: -Padding.large // To Overcome the content padding set by the ApplicationSkeleton
    }

    height: 5
    StyledRect {
        id: track
        z: 0
        anchors.fill: parent
        color: Colors.colLayer2Disabled
    }
    StyledRect {
        id: remaining
        visible: false
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: 1
        }

        rightRadius: Rounding.verysmall
        width: parent.width - progress.width - Padding.verylarge
        color: Colors.colLayer2Hover
    }
    StyledRect {
        id: progress
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        rightRadius: Rounding.verysmall
        width: parent.width * ((pdf_view.currentPage + 1) / pdf.pageCount)
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: Colors.m3.m3secondary
            }
            GradientStop {
                position: 1
                color: Colors.m3.m3primaryFixed
            }
        }
    }
}
