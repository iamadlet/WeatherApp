import Foundation

protocol MainPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapRetry()
    
    // Data Source
    var numberOfSections: Int { get }
    func numberOfItems(in section: Int) -> Int
    func sectionType(for section: Int) -> WeatherSection?
    
    // Models
    func currentWeather() -> CurrentWeatherModel?
    func hourlyWeather(at index: Int) -> HourlyWeatherModel?
    func dailyWeather(at index: Int) -> DailyWeatherModel?
    
    func weekTemperatureRange() -> (min: Double, max: Double)
    func isFirstItem(_ index: Int) -> Bool
}

final class MainPresenter: MainPresenterProtocol {
    weak var view: MainViewProtocol?
    
    private let weatherService: WeatherServiceProtocol
    private let locationService: LocationManagerProtocol
    
    init(weatherService: WeatherServiceProtocol, locationManager: LocationManagerProtocol) {
        self.weatherService = weatherService
        self.locationService = locationManager
    }
    
    private var currentWeatherModel: CurrentWeatherModel?
    private var hourlyWeatherModels: [HourlyWeatherModel] = []
    private var dailyWeatherModels: [DailyWeatherModel] = []
    
    private var weekMinTemp: Double = 0
    private var weekMaxTemp: Double = 0
    
    private var city: String = ""
    
    
    func didTapRetry() {
        loadWeather()
    }
    
    var numberOfSections: Int {
        return WeatherSection.allCases.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        guard let sectionType = WeatherSection(rawValue: section) else {
            return 0
        }
        
        switch sectionType {
        case .current:
            return currentWeatherModel != nil ? 1 : 0
        case .hourly:
            return hourlyWeatherModels.count
        case .daily:
            return dailyWeatherModels.count
        }
    }
    
    func sectionType(for section: Int) -> WeatherSection? {
        return WeatherSection(rawValue: section)
    }
    
    func currentWeather() -> CurrentWeatherModel? {
        currentWeatherModel
    }
    
    func hourlyWeather(at index: Int) -> HourlyWeatherModel? {
        guard index < hourlyWeatherModels.count else { return nil }
        return hourlyWeatherModels[index]
    }
    
    func dailyWeather(at index: Int) -> DailyWeatherModel? {
        guard index < dailyWeatherModels.count else { return nil }
        return dailyWeatherModels[index]
    }
    
    func weekTemperatureRange() -> (min: Double, max: Double) {
        return (weekMinTemp, weekMaxTemp)
    }
    
    func isFirstItem(_ index: Int) -> Bool {
        return index == 0
    }
    
    func viewDidLoad() {
        loadWeather()
    }
    
    func loadWeather() {
        view?.showLoading()
        
        // MARK: - Если пустые/битые координаты
        locationService.getCurrentLocation { [weak self] result in
            switch result {
            case .success(let coordinates):
                self?.fetchWeather(location: coordinates)
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.view?.showError()
                }
            }
        }
    }
    
    func fetchWeather(location: Coordinates) {
        let request = ForecastRequest(
            lat: location.latitude,
            lon: location.longitude,
            appid: Secrets.apiKey
        )
        
        weatherService.fetchWeather(request: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let weather):
                    self.handleWeatherResponse(weather)
                case .failure(let error):
                    self.view?.showError()
                }
            }
        }
    }
    
    func handleWeatherResponse(_ weather: WeatherModel) {
        currentWeatherModel = weather.current
        hourlyWeatherModels = weather.hourly
        dailyWeatherModels = weather.daily
        
        calculateWeekTemperatureRange()
        
        if let current = currentWeatherModel {
            let background = makeBackground(weather: current)
            view?.setBackground(background)
        }
        
        view?.reloadData()
    }
    
    func calculateWeekTemperatureRange() {
        guard !dailyWeatherModels.isEmpty else { return }
        
        weekMinTemp = dailyWeatherModels.map { $0.minTemperature }.min() ?? 0
        weekMaxTemp = dailyWeatherModels.map { $0.maxTemperature }.max() ?? 0
    }
    
    func makeBackground(weather: CurrentWeatherModel) -> WeatherBackground {
        let time = makeDayTime(date: weather.date)
        let rain = isRaining(weatherId: weather.weatherId)
        
        switch(time, rain) {
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

extension MainPresenter {
    private func makeDayTime(date: Date) -> DayTime {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 6..<12: return .morning
        case 12..<18: return .afternoon
        case 18..<22: return .evening
        default: return .night
        }
    }
    
    private func isRaining(weatherId: Int) -> Bool {
        return weatherId >= 200 && weatherId <= 531
    }
}
