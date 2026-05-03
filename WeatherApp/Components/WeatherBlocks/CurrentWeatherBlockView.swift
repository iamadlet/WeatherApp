import UIKit
import SnapKit

final class CurrentWeatherBlockView: UIView {
    let myLocationLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.currentLocationLabel.font
        label.textColor = AppColorManager.primary
        label.textAlignment = .center
        label.text = "Current Location"
        return label
    }()
    
    let cityLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.title.font
        label.textColor = AppColorManager.primary
        label.textAlignment = .center
        return label
    }()
    
    let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.temperatureTitle.font
        label.textColor = AppColorManager.primary
        label.textAlignment = .center
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.subtitle.font
        label.textColor = AppColorManager.subtitleMint
        label.textAlignment = .center
        return label
    }()
    
    let minMaxTemperatureLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.subtitle.font
        label.textColor = AppColorManager.primary
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [
            myLocationLabel, cityLabel, temperatureLabel, descriptionLabel, minMaxTemperatureLabel
        ])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 72, left: 16, bottom: 68, right: 16))
        }
    }
    
    func configure(city: String, current: CurrentWeatherModel, todayDaily: DailyWeatherModel?) {
        cityLabel.text = city
        temperatureLabel.text = "\(Int(current.temperature))°"
        descriptionLabel.text = current.description
        
        if let daily = todayDaily {
            minMaxTemperatureLabel.text = "Max.: \(Int(daily.maxTemperature.rounded()))°, min.:  \(Int(daily.minTemperature.rounded()))°"
        } else {
            minMaxTemperatureLabel.text = ""
        }
    }
}
