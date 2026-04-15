import Foundation
import CoreLocation

protocol LocationManagerProtocol: AnyObject {
    var authorizationStatus: CLAuthorizationStatus { get }
    var currentLocation: CLLocation? { get }
    
    func requestLocation()
}

final class LocationManager: NSObject, LocationManagerProtocol {
    private let manager: CLLocationManager
    
    private(set) var currentLocation: CLLocation?
    
    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }
    
    override init() {
        self.manager = CLLocationManager()
        super.init()
        manager.delegate = self
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
    }
    
    
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        print(location.coordinate.latitude, location.coordinate.longitude)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // TODO: - добавить функционал для этого метода
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
            
        case .denied, .restricted:
            print("Нет доступа к локации")
            
        case .notDetermined:
            break
            
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
