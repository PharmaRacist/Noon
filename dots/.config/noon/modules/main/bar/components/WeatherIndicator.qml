import QtQuick
import qs.services

BarRevealerIndicator {
    readonly property var weatherData: WeatherService.weatherData
    icon: weatherData.currentEmoji
    text: weatherData.currentTemp
    popup: WeatherPopup {}
    Component.onCompleted: WeatherService.loadWeather()
}
