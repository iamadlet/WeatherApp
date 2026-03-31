import Foundation

protocol ApiRequestProtocol {
    associatedtype Response: Decodable
    
    var endpoint: String { get }
    var parameters: [URLQueryItem]? { get }
    var headers: [String: String]? { get }
    
    func makeRequest(host: String) -> URLRequest?
}

extension ApiRequestProtocol {
    var parameters: [URLQueryItem]? {
        return nil
    }
    
    var headers: [String: String]? {
        return ["appid": "\(Secrets.apiKey)"]
    }
    
    func makeRequest(host: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
        urlComponents.path = endpoint
        urlComponents.queryItems = parameters
        
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers?.forEach({ (key: String, value: String) in
            request.addValue(value, forHTTPHeaderField: key)
        })
        
        return request
    }
}
