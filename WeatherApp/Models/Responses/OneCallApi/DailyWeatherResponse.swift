import Foundation

struct DailyWeatherResponse: Decodable {
    let dt: Int
    let temp: DailyTempResponse
    let weather: [WeatherDescriptionResponse]
}

extension DailyWeatherResponse {
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(dt))
    }
}

struct DailyTempResponse: Decodable {
    let min: Double
    let max: Double
}
