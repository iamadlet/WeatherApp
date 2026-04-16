import Foundation

struct CurrentWeatherModel {
    let temperature: Double
    let description: String
    let icon: String
    let humidity: Int
    let windSpeed: Double
}

extension CurrentWeatherModel {
    init?(response: CurrentWeatherResponse) {
        guard let weather = response.weather.first else { return nil }
        
        self.temperature = response.temp
        self.description = weather.description
        self.icon = weather.icon
        self.humidity = response.humidity
        self.windSpeed = response.windSpeed
    }
}
