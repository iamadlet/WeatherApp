import Foundation

struct DailyWeatherModel {
    let date: Date
    let maxTemperature: Double
    let minTemperature: Double
    let main: String
    let weatherId: Int
}

extension DailyWeatherModel {
    init?(response: DailyWeatherResponse) {
        guard let weather = response.weather.first else { return nil }
        
        self.date = response.date
        self.maxTemperature = response.temp.max
        self.minTemperature = response.temp.min
        self.main = weather.main
        self.weatherId = weather.id
    }
}

extension DailyWeatherModel {
    func formattedDay(isToday: Bool = false) -> String {
        if isToday {
            return "Сегодня"
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EE"
        
        let day = formatter.string(from: date)
        
        return day.prefix(1).uppercased() + day.dropFirst()
    }
    
    var formattedMinTemp: String {
        return "\(Int(minTemperature.rounded()))°"
    }
    
    var formattedMaxTemp: String {
        return "\(Int(maxTemperature.rounded()))°"
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
