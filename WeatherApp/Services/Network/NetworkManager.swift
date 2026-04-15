import Foundation

protocol NetworkManagerProtocol {
    var host: String { get }
    func send<T: ApiRequestProtocol>(request: T, completion: @escaping (Result<T.Response, ApiClientError>) -> Void)
}

struct NetworkManager: NetworkManagerProtocol {
    let host: String
    private let token: String
    
    init(host: String, token: String) {
        self.host = host
        self.token = token
    }
    
    func send<T>(
        request: T,
        completion: @escaping (Result<T.Response, ApiClientError>) -> Void
    ) where T : ApiRequestProtocol {
        
        guard let request = request.makeRequest(host: host) else {
            completion(.failure(ApiClientError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error as? URLError {
                switch error.code {
                case .notConnectedToInternet:
                    completion(.failure(ApiClientError.noNetworkConnection))
                case .timedOut:
                    completion(.failure(ApiClientError.timeout))
                default:
                    completion(.failure(ApiClientError.network(error)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(ApiClientError.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 400...499:
                completion(.failure(ApiClientError.clientError(httpResponse.statusCode)))
                return
            case 500...599:
                completion(.failure(ApiClientError.serverError(httpResponse.statusCode)))
                return
            default:
                completion(.failure(ApiClientError.unexpectedStatusCode(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(ApiClientError.noData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(T.Response.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(ApiClientError.decoding(error)))
            }
        }
        task.resume()
    }
}
