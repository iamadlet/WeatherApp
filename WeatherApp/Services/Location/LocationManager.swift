import Foundation
import CoreLocation

protocol LocationManagerProtocol: AnyObject {
    var authorizationStatus: CLAuthorizationStatus { get }
    var currentLocation: CLLocation? { get }
    
    func requestCurrentLocation(completion: @escaping (Double, Double) -> Void)
}

final class LocationManager: NSObject, LocationManagerProtocol {
    private let manager: CLLocationManager
    
    private var onLocation: ((Double, Double) -> Void)?
    
    private(set) var currentLocation: CLLocation?
    
    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }
    
    override init() {
        self.manager = CLLocationManager()
        super.init()
        manager.delegate = self
    }
    
    func requestCurrentLocation(completion: @escaping (Double, Double) -> Void) {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
        
        self.onLocation = completion
    }
    
    
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last?.coordinate else { return }
        
        onLocation?(location.latitude, location.longitude)
        print(location.latitude, location.longitude)
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
