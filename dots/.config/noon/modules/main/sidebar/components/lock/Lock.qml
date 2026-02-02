import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

StyledRect {
    id: root

    anchors.fill: parent
    anchors.margins: Padding.small
    radius: Rounding.verylarge
    color: Colors.colLayer1
    Component.onCompleted: GlobalStates.main.lock = Qt.binding(() => root)
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
    }

    ColumnLayout {
        id: clock
        anchors.centerIn: parent
        spacing: -25 * scale

        property int wght: active ? 1000 : Mem.states.fonts.variableAxes.display.wght
        property int wdth: active ? 0 : Mem.states.fonts.variableAxes.display.wdth

        readonly property real scale: Mem.states.desktop.clock.scale
        readonly property bool active: hoverArea.containsMouse || inputArea.focus

        StyledText {
            id: hour
            text: DateTimeService.cleanHour
            font.pixelSize: 100 * clock.scale
            color: clock.active ? Colors.colPrimary : Colors.colOnBackground
            font.variableAxes: {
                "wdth": clock.wdth,
                "wght": clock.wght
            }
        }

        StyledText {
            id: minute
            text: DateTimeService.cleanMinute
            font.pixelSize: 100 * clock.scale
            color: clock.active ? Colors.colSecondary : Colors.colOnBackground
            font.variableAxes: hour.font.variableAxes
        }

        Behavior on wght {
            Anim {}
        }
        Behavior on wdth {
            Anim {}
        }
    }

    RowLayout {
        anchors {
            top: clock.bottom
            right: parent.right
            left: parent.left
            topMargin: Padding.massive
            leftMargin: Padding.massive * 2
            rightMargin: Padding.massive * 2
        }
        implicitHeight: 46
        spacing: Padding.huge

        MaterialShapeWrappedMaterialSymbol {
            shape: MaterialShape.Shape.Ghostish
            color: Colors.colPrimary
            implicitSize: 38
            text: "lock"
            colSymbol: Colors.colOnPrimary
            fill: 1
        }

        MaterialTextArea {
            id: inputArea
            implicitHeight: 46
            implicitWidth: 200

            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
