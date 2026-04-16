import Foundation

enum ApiClientError: Error {
    case invalidRequest
    
    case noNetworkConnection
    case timeout
    case network(Error)
    
    case clientError(Int)
    case serverError(Int)
    case unexpectedStatusCode(Int)

    case noData
    case decodingError
    case invalidResponse
}
