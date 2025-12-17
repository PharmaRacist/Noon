import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs.store

MouseArea {
    id: root

    property bool verticalMode: false
    property var weatherData: WeatherService.weatherData
    property bool expanded: root.containsMouse

    onClicked: expanded = !expanded
    hoverEnabled: true
    implicitHeight: verticalMode ? content.implicitHeight + 5 : BarData.currentBarExclusiveSize
    implicitWidth: verticalMode ? BarData.currentBarExclusiveSize : content.implicitWidth

    GridLayout {
        id: content

        anchors.fill: parent
        Component.onCompleted: WeatherService.loadWeather()
        rows: verticalMode ? 2 : 1
        columns: verticalMode ? 1 : 2

        MaterialSymbol {
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
