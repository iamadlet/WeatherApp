import Foundation

struct ReverseGeocodingRequest: ApiRequestProtocol {
    typealias Response = ReverseGeocodingResponse
    
    var endpoint: String { "geo/1.0/reverse" }
    
    var parameters: [URLQueryItem]? {
        [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: appid)
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
