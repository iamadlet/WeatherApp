import Foundation

protocol MainPresenterProtocol: AnyObject {
    func getLocation()
    func loadWeather()
}

final class MainPresenter: MainPresenterProtocol {
    private var location: Coordinates?
    
    private let locationManager: LocationManagerProtocol
    private let networkManager: NetworkManagerProtocol
    
    init(locationManager: LocationManagerProtocol, networkManager: NetworkManagerProtocol) {
        self.locationManager = locationManager
        self.networkManager = networkManager
    }
    
    func getLocation() {
        locationManager.requestCurrentLocation { [weak self] lat, lon in
            self?.location = Coordinates(latitude: lat, longitude: lon)
            self?.loadWeather()
            
        }
    }
    
    func loadWeather() {
        
    }
}
