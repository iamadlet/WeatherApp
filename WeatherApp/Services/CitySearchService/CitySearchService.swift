import Foundation
import MapKit

protocol CitySearchServiceProtocol: AnyObject {
    var onSuggestionsUpdate: (([CitySuggestion]) -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    
    func updateQuery(_ query: String)
    func searchCities(query: String, completion: @escaping (Result<[CitySuggestion], Error>) -> Void)
    func resolveCoordinates(for suggestion: CitySuggestion, completion: @escaping (Result<City, Error>) -> Void)
}

enum CitySearchError: Error {
    case noResults
    case invalidPlacemark
}

final class CitySearchService: NSObject, CitySearchServiceProtocol {
    
    var onSuggestionsUpdate: (([CitySuggestion]) -> Void)?
    var onError: ((Error) -> Void)?
    
    private let completer: MKLocalSearchCompleter
    private var pendingCompletion: ((Result<[CitySuggestion], Error>) -> Void)?
    
    override init() {
        self.completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address]
    }
    
    func updateQuery(_ query: String) {
        guard !query.isEmpty else {
            onSuggestionsUpdate?([])
            return
        }
        completer.queryFragment = query
    }
    
    func searchCities(query: String,
                      completion: @escaping (Result<[CitySuggestion], Error>) -> Void) {
        guard !query.isEmpty else {
            completion(.success([]))
            return
        }
        // Перезаписываем completion — отвечаем только на последний запрос
        pendingCompletion = completion
        completer.queryFragment = query
    }
    
    func resolveCoordinates(
        for suggestion: CitySuggestion,
        completion: @escaping (Result<City, Error>) -> Void
    ) {
        let queryString = suggestion.subtitle.isEmpty
            ? suggestion.title
            : "\(suggestion.title), \(suggestion.subtitle)"
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = queryString
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let item = response?.mapItems.first else {
                completion(.failure(CitySearchError.noResults))
                return
            }
            let placemark = item.placemark
            let coordinate = placemark.coordinate
            let cityName = placemark.locality ?? suggestion.title
            
            let city = City(
                name: cityName,
                country: placemark.isoCountryCode ?? "",
                state: placemark.administrativeArea,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            completion(.success(city))
        }
    }
}

extension CitySearchService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let suggestions = completer.results.map {
            CitySuggestion(title: $0.title, subtitle: $0.subtitle)
        }
        onSuggestionsUpdate?(suggestions)
        pendingCompletion?(.success(suggestions))
        pendingCompletion = nil
    }
    
    func completer(_ completer: MKLocalSearchCompleter,
                   didFailWithError error: Error) {
        onError?(error)
        pendingCompletion?(.failure(error))
        pendingCompletion = nil
    }
}

//enum CitySearchError: Error {
//    case noResults
//}
