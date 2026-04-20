protocol WeatherServiceProtocol: AnyObject {
    func fetchWeather(request: ForecastRequest, completion: @escaping (Result<WeatherModel, ApiClientError>) -> Void)
}


final class WeatherService: WeatherServiceProtocol {
    let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchWeather(request: ForecastRequest, completion: @escaping (Result<WeatherModel, ApiClientError>) -> Void) {
        networkManager.send(request: request) { (result: Result<OneCallResponse, ApiClientError>) in
            switch result {
            case .success(let response):
                guard let current = CurrentWeatherModel(response: response.current) else {
                    completion(.failure(.decodingError))
                    return
                }
                
                let hourly = response.hourly.compactMap {
                    HourlyWeatherModel(response: $0)
                }
                
                let daily = response.daily.compactMap {
                    DailyWeatherModel(response: $0)
                }
                
                let data = WeatherModel(
                    current: current,
                    hourly: hourly,
                    daily: daily
                )
                
                completion(.success(data))
                
            case .failure(let error):
                completion(.failure(error))
                print("ERROR: \(error)")
            }
        }
    }
}
