import UIKit

final class MainFactory {
    func make(coordinates: Coordinates? = nil) -> UIViewController {
        let host = "api.openweathermap.org"
        
        let networkManager = NetworkManager(host: host, token: Secrets.apiKey)
        let locationManager = LocationManager()
        
        let weatherService = WeatherService(networkManager: networkManager)
        let geocodingService = GeocodingService(networkManager: networkManager)
        
        let router = MainRouter()
        
        let presenter = MainPresenter(
            weatherService: weatherService,
            geocodingService: geocodingService,
            locationManager: locationManager,
            router: router,
            coordinates: coordinates
        )
        
        let vc = MainViewController(presenter: presenter)
        
        presenter.view = vc
        router.view = vc
        
        return vc
    }
}
