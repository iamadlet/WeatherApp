import Foundation
import UIKit

protocol MainPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapRetry()
    
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
    
    private var weatherModel: WeatherModel?
    
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
        
        fetchLocation { [weak self] coordinates in
            self?.coordinates = coordinates
            self?.fetchAllData(for: coordinates)
        }
    }
    
    private func fetchAllData(for coordinates: Coordinates) {
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
    
    private func fetchLocation(completion: @escaping (Coordinates) -> Void) {
        locationManager.getCurrentLocation { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let coordinates):
                    completion(coordinates)
                case .failure(let error):
                    self.view?.showError()
                }
            }
        }
    }
    
    private func fetchCityName(for coordinates: Coordinates, completion: @escaping () -> Void) {
        let request = ReverseGeocodingRequest(
            lat: coordinates.latitude,
            lon: coordinates.longitude,
            appid: Secrets.apiKey
        )
        
        geocodingService.fetchCityName(request: request) { [weak self] result in
            DispatchQueue.main.async {
                defer { completion() }
                guard let self = self else { return }
                switch result {
                case .success(let city):
                    print("City found: \(city.name)")
                    self.city = city.name
                case .failure(let error):
                    self.city = "Unknown city"
                }
            }
        }
    }
    
    private func fetchWeather(for coordinates: Coordinates, completion: @escaping () -> Void) {
        let request = ForecastRequest(
            lat: coordinates.latitude,
            lon: coordinates.longitude,
            appid: Secrets.apiKey
        )
        
        weatherService.fetchWeather(request: request) { [weak self] result in
            DispatchQueue.main.async {
                defer { completion() }
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
    
    private func handleWeatherResponse(_ weather: WeatherModel) {
        weatherModel = weather
        currentWeatherModel = weather.current
        hourlyWeatherModels = weather.hourly
        dailyWeatherModels = weather.daily
        
        calculateWeekTemperatureRange()
    }
    
    private func handleDataLoaded() {
        guard let current = currentWeatherModel, let model = weatherModel else {
            return
        }
        let background = makeBackground(weather: current)
        view?.setBackground(background)
        
        view?.showWeather()
        
        view?.configureCurrentWeather(city: cityName(), current: current, today: dailyWeatherModels.first!)
        view?.configureHourlyWeather(data: hourlyWeatherModels, description: dailyWeatherModels.first?.main.description ?? "", cardColor: background.cardColor)
        view?.configureDailyWeather(data: dailyWeatherModels, weeklyMin: weekMinTemp, weeklyMax: weekMaxTemp, cardColor: background.cardColor)
        let details = makeWeatherDetails(model: model, cardColor: background.cardColor)
        view?.configureWeatherDetails(with: details)
    }
    
    private func makeBackground(weather: CurrentWeatherModel) -> WeatherBackground {
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
    
    private func makeWeatherDetails(model: WeatherModel, cardColor: UIColor?) -> WeatherDetailsModel {
        let current = model.current
        let daily = model.daily
        
        let todayMax = daily.first?.maxTemperature ?? 0
        let avgMax = daily.map { $0.maxTemperature }.reduce(0, +) / Double(max(daily.count, 1))
        let diff = Int((todayMax - avgMax).rounded())
        
        let avgDescription: String
        let avgValue: String
        if diff >= 0 {
            avgValue = "+\(abs(diff))°"
            avgDescription = "above average daily high"
        } else {
            avgValue = "-\(abs(diff))°"
            avgDescription = "below average daily high"
        }
        
        let avgFooter = "Today      Max.:\(Int(todayMax.rounded()))°On average   Max.:\(Int(avgMax.rounded()))°"
        
        let feelsLikeDiff = current.feelsLike - current.temperature
        let feelsLikeFooter: String
        if feelsLikeDiff > 1 {
            feelsLikeFooter = "It feels warmer than it actually is."
        } else if feelsLikeDiff < -1 {
            feelsLikeFooter = "It feels colder than it actually is."
        } else {
            feelsLikeFooter = "Similar to the actual temperature."
        }
        
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let dirIndex = Int((Double(current.windDegree) + 22.5) / 45.0) % 8
        
        let uvIndex = Int(current.uvIndex.rounded())
        let uvLevel: String
        let uvDescription: String
        switch uvIndex {
        case 0...2:
            uvLevel = "Low"
            uvDescription = "Will remain low until the end of the day."
        case 3...5:
            uvLevel = "Moderate"
            uvDescription = "Will remain moderate until the end of the day."
        case 6...7:
            uvLevel = "High"
            uvDescription = "Use sunscreen"
        case 8...10:
            uvLevel = "Very high"
            uvDescription = "Avoid prolonged exposure to the sun."
        default:
            uvLevel = "Extreme"
            uvDescription = "Try not to go outside"
        }
        
        let sunsetTime = formatTime(current.sunset)
        let sunriseTime = formatTime(current.sunrise)
        
        let pressureFooter: String
        if current.pressure > 1013 {
            pressureFooter = "↑ gPa"
        } else if current.pressure < 1013 {
            pressureFooter = "↓ gPa"
        } else {
            pressureFooter = "- gPa"
        }
        
        return WeatherDetailsModel(
            cardColor: cardColor,
            avgValue: avgValue,
            avgDescription: avgDescription,
            avgFooter: avgFooter,
            feelsLike: "\(Int(current.feelsLike.rounded()))°",
            feelsLikeFooter: feelsLikeFooter,
            windSpeed: "\(Int(current.windSpeed.rounded())) km/h",
            windGust: "\(Int(current.windGust.rounded())) km/h",
            windDirection: "\(current.windDegree)° \(directions[dirIndex])",
            uvIndexValue: uvIndex,
            uvLevel: uvLevel,
            uvDescription: uvDescription,
            sunsetTime: sunsetTime,
            sunriseTime: sunriseTime,
            humidity: "\(current.humidity)%",
            humidityDescription: "Dew point:\(Int(current.dewPoint.rounded()))°.",
            pressureValue: "\(current.pressure)",
            pressureFooter: pressureFooter
        )
    }
    
    private func calculateWeekTemperatureRange() {
        guard !dailyWeatherModels.isEmpty else { return }
        
        weekMinTemp = dailyWeatherModels.map { $0.minTemperature }.min() ?? 0
        weekMaxTemp = dailyWeatherModels.map { $0.maxTemperature }.max() ?? 0
    }
    
    private func formatTime(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
