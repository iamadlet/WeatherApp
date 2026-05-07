import UIKit

protocol CityPreviewViewProtocol: AnyObject {
    func showLoading()
    func showError()
    func showWeather()
    func setBackground(_ background: WeatherBackground)
    func setAlreadySaved(_ saved: Bool)
    func dismiss()
    func configureCurrentWeather(city: String, current: CurrentWeatherModel, today: DailyWeatherModel)
    func configureHourlyWeather(data: [HourlyWeatherModel], description: String, cardColor: UIColor?)
    func configureDailyWeather(data: [DailyWeatherModel], weeklyMin: Double, weeklyMax: Double, cardColor: UIColor?)
    func configureWeatherDetails(with details: WeatherDetailsModel, cardColor: UIColor?)
}

protocol CityPreviewPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapAdd()
    func didTapRetry()
}

final class CityPreviewPresenter: CityPreviewPresenterProtocol {
    weak var view: CityPreviewViewProtocol?
    
    private let city: City
    private let weatherService: WeatherServiceProtocol
    private let savedCitiesService: SavedCitiesServiceProtocol
    
    private var weatherModel: WeatherModel?
    private var dailyWeatherModels: [DailyWeatherModel] = []
    private var hourlyWeatherModels: [HourlyWeatherModel] = []
    private var weekMinTemp: Double = 0
    private var weekMaxTemp: Double = 0
    
    init(city: City, weatherService: WeatherServiceProtocol, savedCitiesService: SavedCitiesServiceProtocol) {
        self.city = city
        self.weatherService = weatherService
        self.savedCitiesService = savedCitiesService
    }
    
    func viewDidLoad() {
        let alreadySaved = savedCitiesService.isSaved(id: city.id)
        view?.setAlreadySaved(alreadySaved)
        loadWeather()
    }
    
    func didTapRetry() {
        loadWeather()
    }
    
    func didTapAdd() {
        print("✅ didTapAdd called for: \(city.name)")
        savedCitiesService.add(city)
        view?.dismiss()
    }
}

private extension CityPreviewPresenter {
    func loadWeather() {
        view?.showLoading()
        
        let request = ForecastRequest(
            lat: city.latitude,
            lon: city.longitude,
            appid: Secrets.apiKey
        )
        
        weatherService.fetchWeather(request: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let weather):
                    self.handleWeather(weather)
                case .failure:
                    self.view?.showError()
                }
            }
        }
    }
    
    func handleWeather(_ weather: WeatherModel) {
        weatherModel = weather
        dailyWeatherModels = weather.daily
        hourlyWeatherModels = weather.hourly
        weekMinTemp = weather.daily.map { $0.minTemperature }.min() ?? 0
        weekMaxTemp = weather.daily.map { $0.maxTemperature }.max() ?? 0
        
        guard let current = weather.current as? CurrentWeatherModel,
              let today = dailyWeatherModels.first else { return }
        
        let background = makeBackground(weather: weather.current)
        view?.setBackground(background)
        view?.showWeather()
        view?.configureCurrentWeather(city: city.name, current: weather.current, today: today)
        view?.configureHourlyWeather(data: hourlyWeatherModels, description: today.main.description, cardColor: background.cardColor)
        view?.configureDailyWeather(data: dailyWeatherModels, weeklyMin: weekMinTemp, weeklyMax: weekMaxTemp, cardColor: background.cardColor)
    }
    
    func makeBackground(weather: CurrentWeatherModel) -> WeatherBackground {
        let hour = Calendar.current.component(.hour, from: weather.date)
        let dayTime: DayTime
        switch hour {
        case 6..<12: dayTime = .morning
        case 12..<18: dayTime = .afternoon
        case 18..<22: dayTime = .evening
        default: dayTime = .night
        }
        let rain = weather.weatherId >= 200 && weather.weatherId <= 531
        switch (dayTime, rain) {
        case (.morning, false): return .morning
        case (.afternoon, false): return .afternoon
        case (.evening, false): return .evening
        case (.night, false): return .night
        case (.morning, true): return .rainyMorning
        case (.afternoon, true): return .rainyAfternoon
        case (.evening, true): return .rainyEvening
        case (.night, true): return .rainyNight
        }
    }
}
