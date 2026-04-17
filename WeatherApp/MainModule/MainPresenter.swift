import Foundation

protocol MainPresenterProtocol: AnyObject {
    func loadWeather(location: Coordinates?)
    func makeBackground(weather: CurrentWeatherModel) -> WeatherBackground
}

final class MainPresenter: MainPresenterProtocol {
    private var location: Coordinates?
    private var weather: WeatherModel?
    
    private let weatherService: WeatherServiceProtocol
    
    init(weatherService: WeatherServiceProtocol) {
        self.weatherService = weatherService
    }
    
    func loadWeather(location: Coordinates?) {
        
        // MARK: - Если пустые/битые координаты
        guard let location = location else {
            DispatchQueue.main.async {
                // TODO: Добавить state для пустого массива
            }
            return
        }
        
        // TODO: - Добавить state во время загрузки
        
        // MARK: - Сборка запроса
        let request = ForecastRequest(lat: location.latitude, lon: location.longitude, appid: Secrets.apiKey)
        
        // MARK: - Запрос в сеть
        weatherService.fetchWeather(request: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let weather):
                    self.weather = weather
                    // TODO: Добавить показ экрана с подгруженными данными
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    // TODO: Добавить показ error view state-a
                }
            }
        }
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
