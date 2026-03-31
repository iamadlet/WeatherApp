import Foundation

struct ForecastRequest: ApiRequestProtocol {
    typealias Response = ForecastResponse
    
    var endpoint: String { "/data/2.5/forecast" }
    
    var parameters: [URLQueryItem]? {
        [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
    }
    
    let city: String
    let apiKey: String
    
    init(city: String, apiKey: String) {
        self.city = city
        self.apiKey = apiKey
    }
}
