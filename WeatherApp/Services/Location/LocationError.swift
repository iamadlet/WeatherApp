import Foundation

enum LocationError: Error {
    case denied
    case restricted
    case unknown
    case locationNotFound
    
    var localizedDescription: String {
        switch self {
        case .denied:
            return "Access denied"
        case .restricted:
            return "Access restricted"
        case .unknown:
            return "Unknown error"
        case .locationNotFound:
            return "Unable to find location"
        }
    }
}
