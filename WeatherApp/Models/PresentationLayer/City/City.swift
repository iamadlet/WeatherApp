import Foundation

struct City: Hashable, Codable {
    let id: String
    let name: String
    let country: String
    let state: String?
    let latitude: Double
    let longitude: Double
    
    init(
        name: String,
        country: String,
        state: String? = nil,
        latitude: Double,
        longitude: Double
    ) {
        self.id = "\(latitude)_\(longitude)"
        self.name = name
        self.country = country
        self.state = state
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension City {
    init?(from response: ReverseGeocodingResponse, preferredLanguage: String = "en") {
        let localizedName = response.localNames?[preferredLanguage] ?? response.name
        
        self.init(
            name: localizedName,
            country: response.country,
            state: response.state,
            latitude: response.lat,
            longitude: response.lon
        )
    }
    
    init?(from response: DirectGeocodingResponse, preferredLanguage: String = "en") {
        let localizedName = response.localNames?[preferredLanguage] ?? response.name
        
        self.init(
            name: localizedName,
            country: response.country,
            state: response.state,
            latitude: response.lat,
            longitude: response.lon
        )
    }
    
    init(from savedCity: SavedCity) {
        self.init(
            name: savedCity.name,
            country: savedCity.country,
            state: savedCity.state,        // если есть это поле
            latitude: savedCity.latitude,
            longitude: savedCity.longitude
        )
    }
}
