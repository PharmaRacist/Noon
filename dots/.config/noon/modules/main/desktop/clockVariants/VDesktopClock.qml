import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

Item {
    id: root

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    readonly property real clockScale: Mem.states.desktop.clock.scale
    readonly property bool hovered: hoverArea.containsMouse

    property int wght: hovered ? 1000 : Mem.states.fonts.variableAxes.display.wght
    property int wdth: hovered ? 0 : Mem.states.fonts.variableAxes.display.wdth

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
    }

    ColumnLayout {
        id: layout
        anchors.centerIn: parent
        spacing: -25 * clockScale

        StyledText {
            text: DateTimeService.cleanHour
            font.pixelSize: 100 * clockScale
            color: hovered ? Colors.colPrimary : Colors.colOnBackground
            font.variableAxes: {
                "wdth": root.wdth,
                "wght": root.wght
            }
        }

        StyledText {
            text: DateTimeService.cleanMinute
            font.pixelSize: 100 * clockScale
            color: hovered ? Colors.colSecondary : Colors.colOnBackground
            font.variableAxes: {
                "wdth": root.wdth,
                "wght": root.wght
            }
        }
    }

    // Animations
    Behavior on wght {
        Anim {}
    }
    Behavior on wdth {
        Anim {}
    }
}
