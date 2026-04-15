import Foundation

protocol MainPresenterProtocol: AnyObject {
    func getLocation()
    func getWeather()
}

final class MainPresenter: MainPresenterProtocol {
//    private var location: (Int, Int)
    
    private let locationManager: LocationManagerProtocol
    private let networkManager: NetworkManagerProtocol
    
    init(locationManager: LocationManagerProtocol, networkManager: NetworkManagerProtocol) {
        self.locationManager = locationManager
        self.networkManager = networkManager
    }
    
    func getLocation() {
        locationManager.requestLocation()
    }
    
    func getWeather() {
        
    }
}
