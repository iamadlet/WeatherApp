import Foundation

struct HourlyWeatherModel {
    let date: Date
    let temperature: Double
    let main: String
}

extension HourlyWeatherModel {
    init?(response: HourlyWeatherResponse) {
        guard let weather = response.weather.first else { return nil }
        
        self.date = response.date
        self.temperature = response.temp
        self.main = weather.main
    }
}
