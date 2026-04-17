import UIKit

protocol MainViewProtocol: AnyObject {
    
}

final class MainViewController: UIViewController, MainViewProtocol {
    private let presenter: MainPresenterProtocol
    
    init(presenter: MainPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var mainView = MainView()
    
    override func loadView() {
        self.view = mainView
    }
}
