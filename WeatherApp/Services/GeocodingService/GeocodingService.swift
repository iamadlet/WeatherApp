import Foundation

protocol GeocodingServiceProtocol: AnyObject {
    func fetchCityName(request: ReverseGeocodingRequest, completion: @escaping (Result<ReverseGeocodingModel, ApiClientError>) -> Void)
}

final class GeocodingService: GeocodingServiceProtocol {
    let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchCityName(request: ReverseGeocodingRequest, completion: @escaping (Result<ReverseGeocodingModel, ApiClientError>) -> Void) {
        networkManager.send(request: request) { (result: Result<ReverseGeocodingResponse, ApiClientError>) in
            switch result {
            case .success(let response):
                guard let city = ReverseGeocodingModel(response: response) else {
                    print("Error while decoding city from coordinates")
                    return completion(.failure(.decodingError))
                }
                completion(.success(city))
            case .failure(let error):
                completion(.failure(error))
                print("ERROR: \(error)")
            }
        }
    }
}
