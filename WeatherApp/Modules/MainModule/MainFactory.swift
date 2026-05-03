import UIKit

final class MainFactory {
    func make() -> UIViewController {
        let host = "api.openweathermap.org"
        
        let networkManager = NetworkManager(host: host, token: Secrets.apiKey)
        let locationManager = LocationManager()
        
        let weatherService = WeatherService(networkManager: networkManager)
        let geocodingService = GeocodingService(networkManager: networkManager)
        
        let presenter = MainPresenter(
            weatherService: weatherService,
            geocodingService: geocodingService,
            locationManager: locationManager
        )
        
        let vc = MainViewController(presenter: presenter)
        presenter.view = vc
        
        return vc
    }
}
