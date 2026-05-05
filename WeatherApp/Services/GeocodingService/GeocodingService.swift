import Foundation

protocol GeocodingServiceProtocol: AnyObject {
    func fetchCityName(
        request: ReverseGeocodingRequest,
        completion: @escaping (Result<City, ApiClientError>) -> Void
    )
}

final class GeocodingService: GeocodingServiceProtocol {
    let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchCityName(
        request: ReverseGeocodingRequest,
        completion: @escaping (Result<City, ApiClientError>) -> Void
    ) {
        networkManager.send(request: request) { (result: Result<[ReverseGeocodingResponse], ApiClientError>) in
            switch result {
            case .success(let responses):
                guard let response = responses.first else {
                    print("Empty geocoding response")
                    completion(.failure(.noData))
                    return
                }
                
                guard let city = City(from: response) else {
                    print("Failed to create ReverseGeocodingModel")
                    completion(.failure(.decodingError))
                    return
                }
                
                print("City: \(city.name)")
                completion(.success(city))
                
            case .failure(let error):
                print("Geocoding error: \(error)")
                completion(.failure(error))
            }
        }
    }
}
