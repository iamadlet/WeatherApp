import UIKit

enum AppTextStyle {
    case header
    case title
    case temperatureTitle
    case subtitle
    
    case weatherDescription
    case temperatureForecast
    
    case currentLocationLabel
    
    case weatherCardFooter
}


extension AppTextStyle {
    var font: UIFont {
        switch self {
        case .header:
            return .systemFont(ofSize: 32, weight: .bold)
        case .title:
            return .systemFont(ofSize: 32, weight: .medium)
        case .temperatureTitle:
            return .systemFont(ofSize: 92, weight: .thin)
        case .subtitle:
            return .systemFont(ofSize: 18, weight: .medium)
        case .weatherDescription:
            return .systemFont(ofSize: 14, weight: .regular)
        case .temperatureForecast:
            return .systemFont(ofSize: 15, weight: .medium)
        case .currentLocationLabel:
            return .systemFont(ofSize: 12, weight: .medium)
        case .weatherCardFooter:
            return .systemFont(ofSize: 15, weight: .regular)
        }
        
    }
}
