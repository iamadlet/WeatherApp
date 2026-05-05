import Foundation

struct WeatherModel {
    let timezone: String
    let current: CurrentWeatherModel
    let hourly: [HourlyWeatherModel]
    let daily: [DailyWeatherModel]
}

extension WeatherModel {
    // MARK: - Helpers
    private func formatTime(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
