import Foundation
import CoreLocation

protocol LocationManagerProtocol: AnyObject {
    var authorizationStatus: CLAuthorizationStatus { get }
    var currentLocation: CLLocation? { get }
    
    func requestWhenInUseAuthorization()
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
    
    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print(location.coordinate.latitude, location.coordinate.longitude)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // TODO: - добавить функционал для этого метода
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
            
        case .denied, .restricted:
            print("Нет доступа к локации")
            
        default:
            break
        }
    }
}
