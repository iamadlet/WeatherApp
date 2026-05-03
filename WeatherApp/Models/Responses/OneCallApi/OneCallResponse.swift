import Foundation

struct OneCallResponse: Decodable {
    let lat: Double
    let lon: Double
    let timezone: String
    let timezoneOffset: Int
    
    let current: CurrentWeatherResponse
    let hourly: [HourlyWeatherResponse]
    let daily: [DailyWeatherResponse]
    
    enum CodingKeys: String, CodingKey {
        case lat, lon, timezone, current, hourly, daily
        case timezoneOffset = "timezone_offset"
    }
}
