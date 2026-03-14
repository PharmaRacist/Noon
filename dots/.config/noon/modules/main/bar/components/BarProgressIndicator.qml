import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

MouseArea {
    id: root
    property bool verticalMode: false
    property bool expanded: false

    property string icon
    property var expandedShape: MaterialShape.Shape.Cookie9Sided
    property var collapsedShape: MaterialShape.Shape.Cookie6Sided
    property real value
    property real implicitSize: 32


    property var focusedScreen: MonitorsInfo.focused

    hoverEnabled: true
    Layout.fillHeight: !verticalMode
    Layout.fillWidth: verticalMode

    implicitHeight: content.implicitHeight
    implicitWidth: content.implicitWidth

    onClicked: expanded = !expanded

    Timer {
        id: timeout
        running: expanded
        interval: 2000
        onTriggered: expanded = false
    }

    GridLayout {
        id: content
        anchors.fill: parent
        rows: verticalMode ? 2 : 1
        columns: verticalMode ? 1 : 2
        rowSpacing: Padding.normal
        columnSpacing: Padding.normal

        Revealer {
            id: revealer
            Layout.alignment: Qt.AlignHCenter
            reveal: root.containsMouse || root.expanded
            vertical: true

            ClippedProgressBar {
                visible: parent.reveal
                anchors.centerIn: parent
                vertical: root.verticalMode
                value: root.value
                valueBarHeight: 80
                valueBarWidth: 20
                highlightColor: Colors.colPrimary
                trackColor: Colors.colLayer3
            }
        }

        MaterialShapeWrappedMaterialSymbol {
            id: symbol
            fill: 1
            Layout.alignment: Qt.AlignHCenter
            color: Colors.colPrimary
            colSymbol: Colors.colOnPrimary
            implicitSize: root.implicitSize

            states: [
                State {
                    name: "revealed"
                    when: revealer.reveal
                    PropertyChanges {
                        target: symbol
                        text: Math.round(100 * root.value)
                        shape: root.expandedShape
                        font.family: Fonts.family.main
                        font.pixelSize: Fonts.sizes.verysmall
                    }
                },
                State {
                    name: "collapsed"
                    when: !revealer.reveal
                    PropertyChanges {
                        target: symbol
                        text: root.icon
                        shape: root.collapsedShape
                        font.family: Fonts.family.iconMaterial
                        font.pixelSize: Fonts.sizes.small
                    }
                }
            ]
        }
    }
}
