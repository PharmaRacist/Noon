import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Item {
    id: root
    property bool verticalMode: false
    property var weatherData: WeatherService.weatherData

    Component.onCompleted: WeatherService.loadWeather()

    Layout.fillHeight: true
    Loader {
        id: contentLoader
        anchors.fill: parent
        sourceComponent: verticalMode ? weatherColumn : weatherRow
    }

    Component {
        id: weatherColumn
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 4
            MaterialSymbol {
                text: weatherData.currentEmoji
                iconSize: Fonts.sizes.large
                color: Colors.colOnLayer1
                fill: 1
                horizontalAlignment: Text.AlignHCenter
            }

            StyledText {
                text: weatherData.currentTemp
                font.pixelSize: Fonts.sizes.normal
                font.family: Fonts.family.main
                color: Colors.colOnLayer1
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Component {
        id: weatherRow
        RowLayout {
            spacing: 8
            implicitHeight: 35
            MaterialSymbol {
                text: weatherData.currentEmoji
                iconSize: Fonts.sizes.normal
                color: Colors.colOnLayer1
                fill: 1
            }

            StyledText {
                text: weatherData.currentTemp
                font.pixelSize: Fonts.sizes.normal
                font.family: Fonts.family.main
                color: Colors.colOnLayer1
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        ToolTip.visible: containsMouse
        ToolTip.text: weatherData.currentCondition
        ToolTip.delay: 500
    }
}
