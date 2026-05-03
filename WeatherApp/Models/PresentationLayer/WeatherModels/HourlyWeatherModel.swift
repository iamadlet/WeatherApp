import Foundation

struct HourlyWeatherModel {
    let date: Date
    let temperature: Double
    let main: String
    let weatherId: Int
}

extension HourlyWeatherModel {
    init?(response: HourlyWeatherResponse) {
        guard let weather = response.weather.first else { return nil }
        
        self.date = response.date
        self.temperature = response.temp
        self.main = weather.main
        self.weatherId = weather.id
    }
}

extension HourlyWeatherModel {
    func formattedTime(isNow: Bool = false) -> String {
        if isNow {
            return "Now"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        return formatter.string(from: date)
    }
    
    var formattedTemperature: String {
        return "\(Int(temperature.rounded()))°"
    }
    
    var iconName: String {
        switch weatherId {
        case 200...531: return "rain"
        case 800: return "sun"
        case 801...804: return "cloud"
        default: return "moon2"
        }
    }
}
