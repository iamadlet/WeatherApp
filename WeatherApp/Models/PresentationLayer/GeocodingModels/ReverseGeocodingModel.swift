import Foundation

struct ReverseGeocodingModel {
    let name: String
    let country: String
}

extension ReverseGeocodingModel {
    init?(response: ReverseGeocodingResponse) {
        self.name = response.name
        self.country = response.country
    }
}
