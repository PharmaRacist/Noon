import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services
import qs.store

MouseArea {
    id: root

    property bool verticalMode: false
    property var weatherData: WeatherService.weatherData
    property bool expanded: root.containsMouse

    onClicked: expanded = !expanded
    hoverEnabled: true
    implicitHeight: verticalMode ? children[0].implicitHeight : BarData.currentBarExclusiveSize
    implicitWidth: verticalMode ? BarData.currentBarExclusiveSize : children[0].implicitWidth
    Layout.leftMargin: verticalMode ? 0 : Padding.normal
    Layout.rightMargin: verticalMode ? Padding.normal : 0
    GridLayout {
        id: content

        anchors.centerIn: parent
        Component.onCompleted: WeatherService.loadWeather()
        rows: verticalMode ? 2 : 1
        columns: verticalMode ? 1 : 2

        Symbol {
            fill: 1
            text: weatherData.currentEmoji
            font.pixelSize: BarData.currentBarExclusiveSize / 2
            color: Colors.colOnLayer1
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Revealer {
            id: revealer

            Layout.topMargin: -4
            reveal: root.containsMouse || root.expanded
            vertical: root.verticalMode
            Layout.alignment: Qt.AlignHCenter

            StyledText {
                visible: parent.reveal
                anchors.centerIn: parent
                text: weatherData.currentTemp
                font.pixelSize: verticalMode ? Fonts.sizes.small : Fonts.sizes.normal
                color: Colors.colOnLayer1
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    WeatherPopup {
        hoverTarget: root
    }
}
