import Foundation
import CoreLocation

protocol LocationManagerProtocol: AnyObject {
    var authorizationStatus: CLAuthorizationStatus { get }
    var currentLocation: CLLocation? { get }
    
    func getCurrentLocation(completion: @escaping (Result<Coordinates, LocationError>) -> Void)
}

final class LocationManager: NSObject, LocationManagerProtocol {
    private let manager: CLLocationManager
    
    private var completion: ((Result<Coordinates, LocationError>) -> Void)?
    
    private(set) var currentLocation: CLLocation?
    
    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }
    
    override init() {
        self.manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func getCurrentLocation(completion: @escaping (Result<Coordinates, LocationError>) -> Void) {
        self.completion = completion
        
        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
            
        case .denied:
            completion(.failure(.denied))
            
        case .restricted:
            completion(.failure(.restricted))
        
        @unknown default:
            completion(.failure(.unknown))
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else {
            completion?(.failure(.locationNotFound))
            completion = nil
            return
        }
        
        currentLocation = location
        
        let coordinates = Coordinates(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        completion?(.success(coordinates))
        completion = nil
        
        print("Location: \(coordinates.latitude), \(coordinates.longitude)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // TODO: - добавить функционал для этого метода
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if completion != nil {
                manager.requestLocation()
            }
            
        case .denied:
            completion?(.failure(.denied))
            completion = nil
            
        case .restricted:
            completion?(.failure(.restricted))
            completion = nil
            
        case .notDetermined:
            break
            
        @unknown default:
            completion?(.failure(.unknown))
            completion = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Location error: \(error.localizedDescription)")
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                completion?(.failure(.denied))
            case .locationUnknown:
                completion?(.failure(.locationNotFound))
            default:
                completion?(.failure(.unknown))
            }
        } else {
            completion?(.failure(.unknown))
        }
        
        completion = nil
    }
}
