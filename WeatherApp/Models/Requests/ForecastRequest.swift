import Foundation

struct ForecastRequest: ApiRequestProtocol {
    typealias Response = OneCallResponse
    
    var endpoint: String { "/data/2.5/forecast" }
    
    var parameters: [URLQueryItem]? {
        [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: appid),
            URLQueryItem(name: "units", value: "metric")
        ]
    }
    
    let city: String
    let appid: String
    
    init(city: String, appid: String) {
        self.city = city
        self.appid = appid
    }
}
