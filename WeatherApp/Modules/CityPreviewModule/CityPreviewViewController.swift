import UIKit

final class CityPreviewViewController: UIViewController {
    private let presenter: CityPreviewPresenterProtocol
    private let onDismiss: () -> Void
    private lazy var previewView = CityPreviewView()
    
    init(presenter: CityPreviewPresenterProtocol, onDismiss: @escaping () -> Void) {
        self.presenter = presenter
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = previewView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCallbacks()
        presenter.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
            onDismiss()
        }
    }
    
    private func setupCallbacks() {
        previewView.onCloseTapped = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        previewView.onAddTapped = { [weak self] in
            self?.presenter.didTapAdd()
        }
        
        previewView.onRetryTapped = { [weak self] in
            self?.presenter.didTapRetry()
        }
    }
}

extension CityPreviewViewController: CityPreviewViewProtocol {
    func showLoading() { previewView.showLoading() }
    func showError() { previewView.showError() }
    func showWeather() { previewView.showWeather() }
    func setBackground(_ background: WeatherBackground) { previewView.setBackground(background) }
    func setAlreadySaved(_ saved: Bool) { previewView.setAlreadySaved(saved) }
    func dismiss() { dismiss(animated: true) }
    
    func configureCurrentWeather(city: String, current: CurrentWeatherModel, today: DailyWeatherModel) {
        previewView.weatherView.currentWeatherView.configure(city: city, current: current, todayDaily: today)
    }
    
    func configureHourlyWeather(data: [HourlyWeatherModel], description: String, cardColor: UIColor?) {
        previewView.weatherView.hourlyWeatherView.configure(with: data, description: description, cardColor: cardColor)
    }
    
    func configureDailyWeather(data: [DailyWeatherModel], weeklyMin: Double, weeklyMax: Double, cardColor: UIColor?) {
        previewView.weatherView.dailyWeatherView.configure(with: data, weeklyMin: weeklyMin, weeklyMax: weeklyMax, cardColor: cardColor)
    }
    
    func configureWeatherDetails(with details: WeatherDetailsModel, cardColor: UIColor?) {
        previewView.weatherView.weatherDetailsGridView.configure(with: details, cardColor: cardColor)
    }
}
