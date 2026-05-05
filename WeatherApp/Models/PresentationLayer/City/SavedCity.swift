import Foundation

struct SavedCity: Codable, Hashable {
    let id: String
    let name: String
    let country: String
    let state: String?
    let latitude: Double
    let longitude: Double
    let addedAt: Date
    let isCurrentLocation: Bool
}

extension SavedCity {
    init(city: City, addedAt: Date = Date(), isCurrentLocation: Bool = false) {
        self.id = city.id
        self.name = city.name
        self.country = city.country
        self.state = city.state
        self.latitude = city.latitude
        self.longitude = city.longitude
        self.addedAt = addedAt
        self.isCurrentLocation = isCurrentLocation
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        country = try container.decode(String.self, forKey: .country)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        addedAt = try container.decode(Date.self, forKey: .addedAt)
        // ← если поля нет в старых данных — ставим false
        isCurrentLocation = try container.decodeIfPresent(Bool.self, forKey: .isCurrentLocation) ?? false
    }
    
    func toCity() -> City {
        City(
            name: name,
            country: country,
            state: state,
            latitude: latitude,
            longitude: longitude
        )
    }
}
