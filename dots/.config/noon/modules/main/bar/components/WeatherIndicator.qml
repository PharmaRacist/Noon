import QtQuick
import qs.services

BarRevealerIndicator {
    readonly property var weatherData: WeatherService.weatherData
    icon: weatherData.currentEmoji
    text: weatherData.currentTemp.slice(0, -1)
    popup: WeatherPopup {}
    Component.onCompleted: WeatherService.loadWeather()
}
