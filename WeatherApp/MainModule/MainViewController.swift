import UIKit

protocol MainViewProtocol: AnyObject {
    func showWeather()
    func showError()
    func showLoading()
    func setBackground(_ background: WeatherBackground)
    
    func configureCurrentWeather(city: String, current: CurrentWeatherModel, today: DailyWeatherModel)
    func configureHourlyWeather(data: [HourlyWeatherModel], description: String, cardColor: UIColor?)
    func configureDailyWeather(data: [DailyWeatherModel], weeklyMin: Double, weeklyMax: Double, cardColor: UIColor?)
    func configureWeatherDetails(with details: WeatherDetailsModel)
}

final class MainViewController: UIViewController {
    private let presenter: MainPresenterProtocol
    
    private lazy var mainView = MainView()
    
    init(presenter: MainPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCallBacks()
        
        print("WeatherViewController loaded")
        presenter.viewDidLoad()
    }
    
    private func setupCallBacks() {
        mainView.onRetryTapped = { [weak self] in
            self?.presenter.didTapRetry()
        }
    }
}

extension MainViewController: MainViewProtocol {
    func configureCurrentWeather(city: String, current: CurrentWeatherModel, today: DailyWeatherModel) {
        mainView.weatherView.currentWeatherView.configure(
            city: city,
            current: current,
            todayDaily: today
        )
    }
    
    func configureHourlyWeather(data: [HourlyWeatherModel], description: String, cardColor: UIColor?) {
        mainView.weatherView.hourlyWeatherView.configure(
            with: data,
            description: description,
            cardColor: cardColor
        )
    }
    
    func configureDailyWeather(data: [DailyWeatherModel], weeklyMin: Double, weeklyMax: Double, cardColor: UIColor?) {
        mainView.weatherView.dailyWeatherView.configure(
            with: data,
            weeklyMin: weeklyMin,
            weeklyMax: weeklyMax,
            cardColor: cardColor
        )
    }
    
    func configureWeatherDetails(with details: WeatherDetailsModel) {
        mainView.weatherView.weatherDetailsGridView.configure(with: details)
    }
    
    func setBackground(_ background: WeatherBackground) {
        mainView.setBackground(background)
    }
    
    func showWeather() {
        mainView.showWeather()
    }
    
    func showError() {
        mainView.showError()
    }
    
    func showLoading() {
        mainView.showLoading()
    }
}
