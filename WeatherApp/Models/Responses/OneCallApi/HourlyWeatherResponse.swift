import Foundation

struct HourlyWeatherResponse: Decodable {
    let dt: Int
    let temp: Double
    let weather: [WeatherDescriptionResponse]
}

extension HourlyWeatherResponse {
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(dt))
    }
}
