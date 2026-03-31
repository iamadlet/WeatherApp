struct RainResponse: Decodable {
    let volumeFor3Hours: Double
    
    enum CodingKeys: String, CodingKey {
        case volumeFor3Hours = "3h"
    }
}
