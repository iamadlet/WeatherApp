import Foundation

struct CityResponse: Decodable {
    let id: Int
    let name: String
    let coord: CoordResponse
    let country: String
    let population: Int
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}

extension CityResponse {
    var sunriseDate: Date {
        Date(timeIntervalSince1970: TimeInterval(sunrise))
    }
    
    var sunsetDate: Date {
        Date(timeIntervalSince1970: TimeInterval(sunset))
    }
}
