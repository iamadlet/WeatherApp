import UIKit
import SnapKit

final class MainView: UIView {
    
    var onRetryTapped: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var weatherView: WeatherCollectionView = {
        let view = WeatherCollectionView()
        view.isHidden = true
        return view
    }()
    
    lazy var loadingView: LoadingView = {
        let view = LoadingView()
        view.isHidden = true
        return view
    }()
    
    lazy var errorView: ErrorView = {
        let view = ErrorView()
        view.isHidden = true
        return view
    }()
    
    func showLoading() {
        loadingView.isHidden = false
        errorView.isHidden = true
        weatherView.isHidden = true
        bringSubviewToFront(loadingView)
    }
    
    func showError() {
        errorView.isHidden = false
        loadingView.isHidden = true
        weatherView.isHidden = true
        bringSubviewToFront(errorView)
    }
    
    func showWeather() {
        weatherView.isHidden = false
        loadingView.isHidden = true
        errorView.isHidden = true
        bringSubviewToFront(weatherView)
    }
    
    func reloadData() {
        weatherView.collectionView.reloadData()
    }
    
    func setBackground(_ background: WeatherBackground) {
        UIView.transition(with: backgroundImageView, duration: 0.3, options: .transitionCrossDissolve) {
            self.backgroundImageView.image = UIImage(named: background.rawValue)
        }
    }
}

private extension MainView {
    func commonInit() {
        backgroundColor = .systemBlue
        setupSubviews()
        setupConstraints()
    }
    
    func setupSubviews() {
        addSubview(loadingView)
        addSubview(errorView)
        addSubview(weatherView)
    }
    
    func setupConstraints() {
        [loadingView, errorView, weatherView].forEach { view in
            snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func setupCallbacks() {
        errorView.onRetryTapped = { [weak self] in
            self?.onRetryTapped?()
        }
    }
}
