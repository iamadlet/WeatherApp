import Foundation

protocol MainPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapRetry()
    
    // Data Source
    var numberOfSections: Int { get }
    func numberOfItems(in section: Int) -> Int
    func sectionType(for section: Int) -> WeatherSection?
    
    // Models
    func cityName() -> String
    func currentWeather() -> CurrentWeatherModel?
    func hourlyWeather(at index: Int) -> HourlyWeatherModel?
    func dailyWeather(at index: Int) -> DailyWeatherModel?
    
    func todayDailyWeather() -> DailyWeatherModel?
    
    func weekTemperatureRange() -> (min: Double, max: Double)
    func isFirstItem(_ index: Int) -> Bool
}

final class MainPresenter: MainPresenterProtocol {
    weak var view: MainViewProtocol?
    
    private let weatherService: WeatherServiceProtocol
    private let geocodingService: GeocodingServiceProtocol
    private let locationManager: LocationManagerProtocol
    
    init(weatherService: WeatherServiceProtocol, geocodingService: GeocodingServiceProtocol, locationManager: LocationManagerProtocol) {
        self.weatherService = weatherService
        self.geocodingService = geocodingService
        self.locationManager = locationManager
    }
    
    private var currentWeatherModel: CurrentWeatherModel?
    private var hourlyWeatherModels: [HourlyWeatherModel] = []
    private var dailyWeatherModels: [DailyWeatherModel] = []
    
    private var weekMinTemp: Double = 0
    private var weekMaxTemp: Double = 0
    
    private var city: String = ""
    private var coordinates: Coordinates?
    
    
    func cityName() -> String {
        return city
    }
    
    func todayDailyWeather() -> DailyWeatherModel? {
        return dailyWeatherModels.first
    }
    
    func didTapRetry() {
        loadData()
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
        loadData()
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

private extension MainPresenter {
    func loadData() {
        view?.showLoading()
        
        // MARK: - Если пустые/битые координаты
        fetchLocation { [weak self] coordinates in
            self?.coordinates = coordinates
            self?.fetchAllData(for: coordinates)
        }
    }
    
    func fetchAllData(for coordinates: Coordinates) {
        let group = DispatchGroup()
        
        group.enter()
        fetchCityName(for: coordinates) {
            group.leave()
        }
        
        group.enter()
        fetchWeather(for: coordinates) {
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.handleDataLoaded()
        }
    }
    
    func fetchLocation(completion: @escaping (Coordinates) -> Void) {
        locationManager.getCurrentLocation { [weak self] result in
            switch result {
            case .success(let coordinates):
                completion(coordinates)
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.view?.showError()
                }
            }
        }
    }
    
    func fetchCityName(for coordinates: Coordinates, completion: @escaping () -> Void) {
        let request = ReverseGeocodingRequest(
            lat: coordinates.latitude,
            lon: coordinates.longitude,
            appid: Secrets.apiKey
        )
        
        geocodingService.fetchCityName(request: request) { [weak self] result in
            switch result {
            case .success(let city):
                print("City found: \(city.name)")
                self?.city = city.name
            case .failure(let error):
                self?.city = "Unknown city"
            }
            completion()
        }
    }
    
    func fetchWeather(for coordinates: Coordinates, completion: @escaping () -> Void) {
        let request = ForecastRequest(
            lat: coordinates.latitude,
            lon: coordinates.longitude,
            appid: Secrets.apiKey
        )
        
        weatherService.fetchWeather(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let weather):
                self.handleWeatherResponse(weather)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view?.showError()
                }
            }
            completion()
        }
    }
    
    func handleWeatherResponse(_ weather: WeatherModel) {
        currentWeatherModel = weather.current
        hourlyWeatherModels = weather.hourly
        dailyWeatherModels = weather.daily
        
        calculateWeekTemperatureRange()
    }
    
    func handleDataLoaded() {
        if let current = currentWeatherModel {
            let background = makeBackground(weather: current)
            view?.setBackground(background)
        }
        
        view?.reloadData()
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
    
    func calculateWeekTemperatureRange() {
        guard !dailyWeatherModels.isEmpty else { return }
        
        weekMinTemp = dailyWeatherModels.map { $0.minTemperature }.min() ?? 0
        weekMaxTemp = dailyWeatherModels.map { $0.maxTemperature }.max() ?? 0
    }
}
