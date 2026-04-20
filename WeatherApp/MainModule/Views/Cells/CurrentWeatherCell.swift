import UIKit
import SnapKit

final class CurrentWeatherCell: UICollectionViewCell {
    static let identifier = "CurrentWeatherCell"
    
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CurrentWeatherCell {
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [
            cityLabel,
            temperatureLabel,
            descriptionLabel,
            minMaxTemperatureLabel
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(weather: WeatherModel, city: String) {
        cityLabel.text = city
        temperatureLabel.text = "\(weather.current.temperature)°C"
        descriptionLabel.text = weather.current.description
        minMaxTemperatureLabel.text = "Max.: \(String(describing: weather.daily.first?.maxTemperature))°C, min.:  \(String(describing: weather.daily.first?.minTemperature))°C"
    }
}
