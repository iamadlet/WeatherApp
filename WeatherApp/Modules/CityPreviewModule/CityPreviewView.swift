import UIKit
import SnapKit

final class CityPreviewView: UIView {
    
    var onCloseTapped: (() -> Void)?
    var onAddTapped: (() -> Void)?
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
    
    // MARK: - Top bar
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        button.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Actions
    @objc private func closeTapped() { onCloseTapped?() }
    @objc private func addTapped() { onAddTapped?() }
    
    // MARK: - Public
    func showLoading() {
        loadingView.isHidden = false
        errorView.isHidden = true
        weatherView.isHidden = true
        bringSubviewToFront(loadingView)
        bringSubviewToFront(closeButton)
        bringSubviewToFront(addButton)
    }
    
    func showError() {
        errorView.isHidden = false
        loadingView.isHidden = true
        weatherView.isHidden = true
        bringSubviewToFront(errorView)
        bringSubviewToFront(closeButton)
        bringSubviewToFront(addButton)
    }
    
    func showWeather() {
        weatherView.isHidden = false
        loadingView.isHidden = true
        errorView.isHidden = true
        bringSubviewToFront(weatherView)
        bringSubviewToFront(closeButton)
        bringSubviewToFront(addButton)
    }
    
    func setBackground(_ background: WeatherBackground) {
        let imageName = background.rawValue
        if let image = UIImage(named: imageName) {
            UIView.transition(with: backgroundImageView, duration: 0.3, options: .transitionCrossDissolve) {
                self.backgroundImageView.image = image
            }
        }
    }
    
    // Скрываем кнопку добавления если город уже сохранён
    func setAlreadySaved(_ saved: Bool) {
        addButton.isHidden = saved
    }
}

private extension CityPreviewView {
    func commonInit() {
        setupSubviews()
        setupConstraints()
        setupCallbacks()
    }
    
    func setupSubviews() {
        addSubview(backgroundImageView)
        addSubview(loadingView)
        addSubview(errorView)
        addSubview(weatherView)
        addSubview(closeButton)
        addSubview(addButton)
    }
    
    func setupConstraints() {
        [backgroundImageView, loadingView, errorView, weatherView].forEach {
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        closeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalTo(safeAreaLayoutGuide).inset(12)
            make.size.equalTo(44)
        }
        
        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(safeAreaLayoutGuide).inset(12)
            make.size.equalTo(44)
        }
    }
    
    func setupCallbacks() {
        errorView.onRetryTapped = { [weak self] in
            self?.onRetryTapped?()
        }
    }
}
