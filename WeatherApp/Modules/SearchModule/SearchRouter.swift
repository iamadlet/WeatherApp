import UIKit

protocol SearchRouterProtocol: AnyObject {
    func openMainModule(for city: SavedCityViewModel)
    func openCityPreview(for city: City)
}

final class SearchRouter: SearchRouterProtocol {
    weak var view: UIViewController?
    var onCityPreviewDismissed: (() -> Void)?
    
    func openMainModule(for city: SavedCityViewModel) {
        let mainVC = MainFactory().make(coordinates: city.coordinates)
        view?.navigationController?.pushViewController(mainVC, animated: true)
    }
    
    func openCityPreview(for city: City) {
        let vc = CityPreviewFactory().make(city: city) { [weak self] in
            self?.onCityPreviewDismissed?()
        }
        vc.modalPresentationStyle = .pageSheet
        view?.present(vc, animated: true)
    }
}
