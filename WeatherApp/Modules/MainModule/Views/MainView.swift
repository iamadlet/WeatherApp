import UIKit
import SnapKit

final class MainView: UIView {
    
    var onRetryTapped: (() -> Void)?
    var onListButtonTapped: (() -> Void)?
    var onRefreshTapped: (() -> Void)?
    
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
    
    lazy var weatherView: WeatherScrollView = {
        let view = WeatherScrollView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    lazy var loadingView: LoadingView = {
        let view = LoadingView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    lazy var errorView: ErrorView = {
        let view = ErrorView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    private lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Иконка
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(named: "list"), for: .normal)
        button.tintColor = .white
        
        // Стилизация (круглая кнопка с размытым фоном)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        
        button.addTarget(self, action: #selector(listButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func listButtonTapped() {
        print("Open Search Module button tapped")
        onListButtonTapped?()
    }
    
    func showLoading() {
        loadingView.isHidden = false
        errorView.isHidden = true
        weatherView.isHidden = true
        bringSubviewToFront(loadingView)
        bringSubviewToFront(listButton)
    }
    
    func showError() {
        errorView.isHidden = false
        loadingView.isHidden = true
        weatherView.isHidden = true
        bringSubviewToFront(errorView)
        bringSubviewToFront(listButton)
    }
    
    func showWeather() {
        weatherView.isHidden = false
        loadingView.isHidden = true
        errorView.isHidden = true
        bringSubviewToFront(weatherView)
        bringSubviewToFront(listButton)
    }
    
    func setBackground(_ background: WeatherBackground) {
        let imageName = background.rawValue
            
        if let image = UIImage(named: imageName) {
            print("Image found: \(imageName)")
            UIView.transition(with: backgroundImageView, duration: 0.3, options: .transitionCrossDissolve) {
                self.backgroundImageView.image = image
            }
        } else {
            print("Image NOT found: \(imageName)")
        }
    }
}

private extension MainView {
    func commonInit() {
        setupSubviews()
        setupConstraints()
    }
    
    func setupSubviews() {
        addSubview(loadingView)
        addSubview(errorView)
        addSubview(weatherView)
        addSubview(backgroundImageView)
        addSubview(listButton)
        
        weatherView.onRefresh = { [weak self] in
            self?.onRefreshTapped?()
        }
    }
    
    func setupConstraints() {
        [loadingView, errorView, weatherView, backgroundImageView].forEach { view in
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        listButton.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(28)
            make.size.equalTo(44)
        }
    }
    
    func setupCallbacks() {
        errorView.onRetryTapped = { [weak self] in
            self?.onRetryTapped?()
        }
    }
}
