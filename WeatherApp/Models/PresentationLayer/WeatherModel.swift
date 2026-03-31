struct WeatherModel {
    let dateText: String
    let temperature: String
    let description: String
    let icon: String
    let humidity: String
    let windSpeed: String
}

extension WeatherModel {
    init?(response: ForecastItemResponse) {
        guard let forecastInfo = response.weather.first else {
            return nil
        }
        
        self.dateText = response.dtTxt
        self.temperature = "\(Int(response.main.temp))"
        self.description = forecastInfo.description
        self.icon = forecastInfo.icon
        self.humidity = "\(response.main.humidity)"
        self.windSpeed = "\(response.wind.speed)"
    }
}
