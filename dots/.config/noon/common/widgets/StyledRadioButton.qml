import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs.common
import qs.common.widgets
import qs.services

RadioButton {
    id: root

    property string description
    property color activeColor: Colors.colPrimary ?? "#685496"
    property color inactiveColor: Colors.m3.m3onSurfaceVariant ?? "#45464F"

    implicitHeight: 40

    PointingHandInteraction {
    }

    indicator: Item {
    }

    contentItem: RowLayout {
        Layout.fillWidth: true
        spacing: 12

        Rectangle {
            id: radio

            Layout.fillWidth: false
            Layout.alignment: Qt.AlignVCenter
            width: 20
            height: 20
            radius: Rounding.full
            border.color: checked ? root.activeColor : root.inactiveColor
            border.width: 2
            color: "transparent"

            // Checked indicator
            Rectangle {
                anchors.centerIn: parent
                width: checked ? 10 : 4
                height: checked ? 10 : 4
                radius: Rounding.full
                color: Colors.colPrimary
                opacity: checked ? 1 : 0

                Behavior on opacity {
                    FAnim {
                    }

                }

                Behavior on width {
                    Anim {
                    }

                }

                Behavior on height {
                    Anim {
                    }

                }

            }

            // Hover
            Rectangle {
                anchors.centerIn: parent
                width: root.hovered ? 40 : 20
                height: root.hovered ? 40 : 20
                radius: Rounding.full
                color: Colors.m3.m3onSurface
                opacity: root.hovered ? 0.1 : 0

                Behavior on opacity {
                    FAnim {
                    }

                }

                Behavior on width {
                    Anim {
                    }

                }

                Behavior on height {
                    Anim {
                    }

                }

            }

        }

        StyledText {
            text: root.description
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            color: Colors.m3.m3onSurface
        }

    }

}
