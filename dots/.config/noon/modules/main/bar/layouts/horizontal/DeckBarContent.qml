import QtQuick
import QtQuick.Layouts
import qs.services
import qs.common
import qs.common.widgets
import qs.modules.main.bar.components

Item {
    id: root
    required property var panel

    anchors {
        fill: parent
        rightMargin: Padding.massive
        leftMargin: Padding.massive
    }

    TaskBar {
        anchors.centerIn: parent
        height: parent.height * 0.8
    }

    RLayout {
        anchors.fill: parent
        spacing: Padding.large
        GP {
            implicitWidth: 115
            RLayout {
                anchors.fill: parent
                anchors.rightMargin: Padding.normal
                anchors.leftMargin: Padding.normal
                spacing: 2
                MainButton {}
                VSeparator {}
                WsIndicator {
                    bar: root.panel
                }
            }
        }
        GP {
            Layout.alignment: Qt.AlignRight
            implicitWidth: rLay.implicitWidth + Padding.massive * 2
            RSLayout {
                id: rLay
                SysTray {
                    visible: model.length > 0
                    bar: root.panel
                }
                StatusIcons {}
                Clock {}
                VSeparator {}
                MinimalBattery {}
            }
        }
    }

    component MainButton: RippleButtonWithIcon {
        materialIcon: "keyboard_command_key"
        implicitSize: height
        Layout.fillHeight: true
        Layout.margins: Padding.tiny
    }

    component WsIndicator: Item {
        required property var bar
        Layout.preferredWidth: height
        Layout.fillHeight: true
        StyledText {
            anchors.centerIn: parent
            animateChange: true
            horizontalAlignment: Text.AlignVCenter | Text.AlignHCenter
            text: MonitorsInfo.monitorFor(bar?.screen).activeWorkspace?.id
            color: Colors.colOnLayer1
            font.weight: 900
            font.pixelSize: Fonts.sizes.normal
        }
    }
    component Clock: StyledText {
        Layout.alignment: Qt.AlignRight
        text: DateTimeService.time
        color: Colors.colOnLayer1
        font.variableAxes: Fonts.variableAxes.title
        font.pixelSize: Fonts.sizes.normal
    }

    component RSLayout: RLayout {
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
    }

    component GP: StyledRect {
        Layout.minimumWidth: 100
        Layout.topMargin: Padding.normal
        Layout.bottomMargin: Padding.normal
        Layout.fillHeight: true
        color: Colors.colLayer2
        radius: Rounding.verylarge
    }
}
