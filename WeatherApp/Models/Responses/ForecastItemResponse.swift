import Foundation

struct ForecastItemResponse: Decodable {
    let dt: Int
    let main: MainWeatherResponse
    let weather: [WeatherDescriptionResponse]
    let clouds: CloudsResponse
    let wind: WindResponse
    let visibility: Int
    let pop: Double
    let rain: RainResponse?
    let sys: SysInfoResponse
    let dtTxt: String
    
    enum CodingKeys: String, CodingKey {
        case dt
        case main
        case weather
        case clouds
        case wind
        case visibility
        case pop
        case rain
        case sys
        case dtTxt = "dt_txt"
    }
}

extension ForecastItemResponse {
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(dt))
    }
}
