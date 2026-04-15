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
    
    func send<T>(request: T, completion: @escaping (Result<T.Response, ApiClientError>) -> Void) where T : ApiRequestProtocol {
        guard let request = request.makeRequest(host: host) else {
            completion(.failure(ApiClientError.request))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(ApiClientError.network))
                return
            }
            
            guard let data = data else {
                completion(.failure(ApiClientError.empty))
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                completion(.failure(ApiClientError.service(httpResponse.statusCode)))
                return
            }
            
            let decoder = JSONDecoder()
            
            guard let result = try? decoder.decode(T.Response.self, from: data) else {
                completion(.failure(ApiClientError.deserialize))
                return
            }
            
            completion(.success(result))
        }
        task.resume()
    }
}
