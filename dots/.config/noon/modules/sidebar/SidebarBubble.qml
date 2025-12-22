import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.widgets

StyledRect {
    property bool show
    property bool rightMode

    visible: width > 0 && !Mem.states.sidebar.behavior.pinned
    enableShadows: true
    radius: Rounding.verylarge
    color: Colors.m3.m3surface
    height: content.implicitHeight + 2 * Padding.large
    width: show ? 55 : 0

    ColumnLayout {
        id: content

        spacing: Padding.verysmall

        anchors {
            centerIn: parent
        }

        RippleButtonWithIcon {
            toggled: Mem.states.sidebar.behavior.pinned
            materialIcon: "push_pin"
            releaseAction: () => {
                return Mem.states.sidebar.behavior.pinned = !Mem.states.sidebar.behavior.pinned;
            }
        }

        Separator {
        }

        RippleButtonWithIcon {
            materialIcon: !visualContainer.rightMode && Mem.states.sidebar.behavior.expanded ? "keyboard_double_arrow_left" : "keyboard_double_arrow_right"
            releaseAction: () => {
                return Mem.states.sidebar.behavior.expanded = !Mem.states.sidebar.behavior.expanded;
            }
        }

    }

    Behavior on height {
        Anim {
        }

    }

    Behavior on width {
        Anim {
        }

    }

}
