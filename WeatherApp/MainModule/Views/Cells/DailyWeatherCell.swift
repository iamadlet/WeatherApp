import UIKit
import SnapKit

final class DailyWeatherCell: UICollectionViewCell {
    static let identifier = "DailyWeatherCell"
    
    let dayLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.subtitle.font
        label.textColor = AppColorManager.primary
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let minTempLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.subtitle.font
        label.textColor = AppColorManager.primary
        label.layer.opacity = 0.52
        return label
    }()
    
    let temperatureBar = TemperatureBarView()
    
    let maxTempLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.subtitle.font
        label.textColor = AppColorManager.primary
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.text = nil
        minTempLabel.text = nil
        maxTempLabel.text = nil
        iconImageView.image = nil
        temperatureBar.reset()
    }
}

extension DailyWeatherCell {
    private func setupUI() {
        contentView.addSubview(dayLabel)
        contentView.addSubview(iconImageView)
        contentView.addSubview(minTempLabel)
        contentView.addSubview(temperatureBar)
        contentView.addSubview(maxTempLabel)
        
        dayLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalTo(dayLabel.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(24)
        }
        
        minTempLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(32)
        }
        
        temperatureBar.snp.makeConstraints { make in
            make.leading.equalTo(minTempLabel.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
        }
        
        maxTempLabel.snp.makeConstraints { make in
            make.leading.equalTo(temperatureBar.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(32)
        }
    }
    
    func configure(with model: DailyWeatherModel, weekMin: Double, weekMax: Double, isToday: Bool = false) {
        // TODO: В будущем поменять, добавить нормальное форматирование
        dayLabel.text = model.formattedDay()
        minTempLabel.text = model.formattedMinTemp
        maxTempLabel.text = model.formattedMaxTemp
        
        iconImageView.image = UIImage(named: model.main)
        iconImageView.tintColor = iconColor(for: model.weatherId)
        
        temperatureBar.configure(
            weekMin: weekMin,
            weekMax: weekMax,
            dayMin: model.minTemperature,
            dayMax: model.maxTemperature
        )
    }
    
    private func iconColor(for id: Int) -> UIColor {
        switch id {
        case 800: return AppColorManager.sun ?? UIColor(.yellow)
        default: return AppColorManager.primary ?? UIColor(.white)
        }
    }
}
