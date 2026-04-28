import Foundation

struct CurrentWeatherModel {
    let date: Date
    let temperature: Double
    let description: String
    let icon: String
    let humidity: Int
    let windSpeed: Double
    let main: String
    let weatherId: Int
    
    let feelsLike: Double
    let pressure: Int
    let uvIndex: Double
    let windGust: Double
    let windDegree: Int
    let sunrise: Int
    let sunset: Int
    let dewPoint: Double
}

extension CurrentWeatherModel {
    init?(response: CurrentWeatherResponse) {
        guard let weather = response.weather.first else { return nil }
        
        self.date = Date(timeIntervalSince1970: TimeInterval(response.dt))
        self.temperature = response.temp
        self.description = weather.description
        self.icon = weather.icon
        self.humidity = response.humidity
        self.main = weather.main
        self.weatherId = weather.id
        
        self.feelsLike = response.feelsLike
        self.pressure = response.pressure
        self.uvIndex = response.uvIndex
        self.windSpeed = response.windSpeed
        self.windGust = response.windGust ?? 0
        self.windDegree = response.windDegree
        self.sunrise = response.sunrise
        self.sunset = response.sunset
        self.dewPoint = response.dewPoint
    }
}
