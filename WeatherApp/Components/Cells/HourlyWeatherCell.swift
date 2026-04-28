import UIKit
import SnapKit

final class HourlyWeatherCell: UICollectionViewCell {
    static let identifier = "HourlyWeatherCell"
    
    let hourLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.temperatureForecast.font
        label.textColor = AppColorManager.primary
        label.textAlignment = .center
        return label
    }()
    
    let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.temperatureForecast.font
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

extension HourlyWeatherCell {
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [
            hourLabel,
            weatherImageView,
            temperatureLabel
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // TODO: - Поменять, сделать фон для всей секции, а не на каждую ячейку
//        stackView.backgroundColor = .clear
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(90)
        }
    }
    
    func configure(with model: HourlyWeatherModel, isNow: Bool = false) {
        hourLabel.text = model.formattedTime(isNow: isNow)
        temperatureLabel.text = model.formattedTemperature
        weatherImageView.image = UIImage(named: model.iconName)
    }
}
