import Foundation

struct CurrentWeatherModel {
    let date: Date
    let temperature: Double
    let description: String
    let icon: String
    let humidity: Int
    let windSpeed: Double
    let main: String
    let weatherId: Int
}

extension CurrentWeatherModel {
    init?(response: CurrentWeatherResponse) {
        guard let weather = response.weather.first else { return nil }
        
        self.date = Date(timeIntervalSince1970: TimeInterval(response.dt))
        self.temperature = response.temp
        self.description = weather.description
        self.icon = weather.icon
        self.humidity = response.humidity
        self.windSpeed = response.windSpeed
        self.main = weather.main
        self.weatherId = weather.id
    }
}
