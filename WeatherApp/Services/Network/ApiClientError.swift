import Foundation

enum ApiClientError: Error {
    case request
    case network
    case empty
    case service(_ code: Int)
    case deserialize
}
