import Foundation

struct CurrentWeatherResponse: Decodable {
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: Double
    let feelsLike: Double
    let pressure: Int
    let uvIndex: Double
    let humidity: Int
    let windSpeed: Double
    let windDegree: Int
    let windGust: Double?
    let dewPoint: Double
    let weather: [WeatherDescriptionResponse]
    
    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, temp, pressure, humidity, weather
        case feelsLike = "feels_like"
        case windSpeed = "wind_speed"
        case windDegree = "wind_deg"
        case windGust = "wind_gust"
        case uvIndex = "uvi"
        case dewPoint = "dew_point"
    }
}

extension CurrentWeatherResponse {
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(dt))
    }
}
