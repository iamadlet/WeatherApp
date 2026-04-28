import UIKit

enum AppColorManager {
    static let primary = UIColor(named: "#FFFBFC")
    static let subtitleMint = UIColor(named: "#C9FFFA")
    static let temperatureBarMint = UIColor(named: "#60DACF")
    static let background = UIColor(named: "#377DC3")
    static let citiesBackground = UIColor(named: "#2B4F73")
    static let settingsBackground = UIColor(named: "#424D5885")
    static let sun = UIColor(named: "#DAC42D")
    static let black = UIColor(named: "#000000")
    static let white = UIColor(named: "#FFFFFF")
    
    // MARK: - Weather Card Backgrounds
    static let morning = UIColor(named: "#377DC3")?.withAlphaComponent(0.48)
    static let afternoon = UIColor(named: "#2F65AF85")?.withAlphaComponent(0.48)
    static let evening = UIColor(named: "#74799A85")?.withAlphaComponent(0.48)
    static let night = UIColor(named: "#10112685")?.withAlphaComponent(0.48)
    
    static let rainyMorning = UIColor(named: "#2F65AF85")?.withAlphaComponent(0.48)
    static let rainyAfternoon = UIColor(named: "#868C9185")?.withAlphaComponent(0.48)
    static let rainyEvening = UIColor(named: "#85879385")?.withAlphaComponent(0.48)
    static let rainyNight = UIColor(named: "#424D5885")?.withAlphaComponent(0.48)
}
