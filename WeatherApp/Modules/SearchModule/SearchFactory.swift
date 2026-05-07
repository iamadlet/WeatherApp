import UIKit

final class SearchFactory {
    func make() -> UIViewController {
        let host = "api.openweathermap.org"
        
        let networkManager = NetworkManager(host: host, token: Secrets.apiKey)
        let locationManager = LocationManager()
        
        let weatherService = WeatherService(networkManager: networkManager)
        let geocodingService = GeocodingService(networkManager: networkManager)
        let citySearchService = CitySearchService()
        let executor = CancellableExecutor()
        let router = SearchRouter()
        
        let presenter = SearchPresenter(
            router: router,
            citySearchService: citySearchService,
            weatherService: weatherService,
            savedCitiesService: SavedCitiesService.shared,
            executor: executor
        )
        
        let vc = SearchViewController(presenter: presenter)
        router.view = vc
        router.onCityPreviewDismissed = { [weak presenter] in
            presenter?.cityPreviewDismissed()
        }
        presenter.view = vc
        
        return vc
    }
}

