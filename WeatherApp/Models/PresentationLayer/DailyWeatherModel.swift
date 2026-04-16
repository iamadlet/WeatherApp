import Foundation

struct DailyWeatherModel {
    let date: Date
    let maxTemperature: Double
    let minTemperature: Double
    let main: String
}

extension DailyWeatherModel {
    init?(response: DailyWeatherResponse) {
        guard let weather = response.weather.first else { return nil }
        
        self.date = response.date
        self.maxTemperature = response.temp.max
        self.minTemperature = response.temp.min
        self.main = weather.main
    }
}
