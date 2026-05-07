import UIKit

protocol MainRouterProtocol: AnyObject {
    func openSearchModule()
}

final class MainRouter: MainRouterProtocol {
    weak var view: UIViewController?
    
    func openSearchModule() {
        let searchVC = SearchFactory().make()
        view?.navigationController?.pushViewController(searchVC, animated: true)
    }
}
