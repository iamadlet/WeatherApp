struct DirectGeocodingResponse: Decodable {
    let name: String
    let country: String
    let lat: Double
    let lon: Double
    let state: String?
    let localNames: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case name, country, lat, lon, state
        case localNames = "local_names"
    }
}
