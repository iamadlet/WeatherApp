import UIKit

enum WeatherBackground: String {
    case morning
    case afternoon
    case evening
    case night
    
    case rainyMorning
    case rainyAfternoon
    case rainyEvening
    case rainyNight
    
    var cardColor: UIColor? {
        switch self {
        case .morning:          return AppColorManager.morning
        case .afternoon:        return AppColorManager.afternoon
        case .evening:          return AppColorManager.evening
        case .night:            return AppColorManager.night
        case .rainyMorning:     return AppColorManager.rainyMorning
        case .rainyAfternoon:   return AppColorManager.rainyAfternoon
        case .rainyEvening:     return AppColorManager.rainyEvening
        case .rainyNight:       return AppColorManager.rainyNight
        }
    }
}

enum DayTime {
    case morning
    case afternoon
    case evening
    case night
}
