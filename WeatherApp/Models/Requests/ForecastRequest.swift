import Foundation

struct ForecastRequest: ApiRequestProtocol {
    typealias Response = OneCallResponse
    
    var endpoint: String { "/data/2.5/forecast" }
    
    var parameters: [URLQueryItem]? {
        [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: appid),
            URLQueryItem(name: "units", value: "metric")
        ]
    }
    
    let lat: Double
    let lon: Double
    let appid: String
    
    init(lat: Double, lon: Double, appid: String) {
        self.lat = lat
        self.lon = lon
        self.appid = appid
    }
}
