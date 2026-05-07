import Foundation

struct DirectGeocodingRequest: ApiRequestProtocol {
    typealias Response = [DirectGeocodingResponse]
    
    var endpoint: String { "/geo/1.0/direct" }
    
    var parameters: [URLQueryItem]? {
        [
            URLQueryItem(name: "q", value: name),
            URLQueryItem(name: "appid", value: appid),
            URLQueryItem(name: "limit", value: "1")
        ]
    }
    
    let name: String
    let appid: String
    
    init(name: String, appid: String) {
        self.name = name
        self.appid = appid
    }
}
