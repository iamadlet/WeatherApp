import UIKit

final class CityPreviewFactory {
    func make(city: City, onDismiss: @escaping () -> Void) -> UIViewController {
        let networkManager = NetworkManager(host: "api.openweathermap.org", token: Secrets.apiKey)
        let weatherService = WeatherService(networkManager: networkManager)
        
        let presenter = CityPreviewPresenter(
            city: city,
            weatherService: weatherService,
            savedCitiesService: SavedCitiesService.shared
        )
        
        let vc = CityPreviewViewController(presenter: presenter, onDismiss: onDismiss)
        presenter.view = vc
        vc.modalPresentationStyle = .pageSheet
        
        return vc
    }
}
