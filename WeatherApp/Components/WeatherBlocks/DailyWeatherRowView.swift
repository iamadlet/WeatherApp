import UIKit
import SnapKit

final class DailyWeatherRowView: UIView {
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.subtitle.font
        label.textColor = AppColorManager.primary
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let minTempLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.subtitle.font
        label.textColor = AppColorManager.primary
        label.layer.opacity = 0.52
        return label
    }()
    
    private let barView = TemperatureBarView()
    
    private let maxTempLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.subtitle.font
        label.textColor = AppColorManager.primary
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        let row = UIStackView(arrangedSubviews: [
            dayLabel, iconImageView, minTempLabel, barView, maxTempLabel
        ])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        
        row.setCustomSpacing(18, after: iconImageView)
        
        addSubview(row)
        row.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
        }
        
        dayLabel.snp.makeConstraints { $0.width.equalTo(80) }
        iconImageView.snp.makeConstraints { $0.width.height.equalTo(24) }
        minTempLabel.snp.makeConstraints { $0.width.equalTo(32) }
        barView.snp.makeConstraints { $0.height.equalTo(4) }
        maxTempLabel.snp.makeConstraints { $0.width.equalTo(32) }
        
//        barView.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        barView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        
//        dayLabel.setContentHuggingPriority(.required, for: .horizontal)
//        iconImageView.setContentHuggingPriority(.required, for: .horizontal)
//        minTempLabel.setContentHuggingPriority(.required, for: .horizontal)
//        maxTempLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    func configure(with model: DailyWeatherModel, weekMin: Double, weekMax: Double, isToday: Bool) {
        dayLabel.text = isToday ? "Today" : model.formattedDay()
        iconImageView.image = UIImage(named: model.iconName)
        minTempLabel.text = model.formattedMinTemp
        maxTempLabel.text = model.formattedMaxTemp
        
        barView.configure(weekMin: weekMin, weekMax: weekMax, dayMin: model.minTemperature, dayMax: model.maxTemperature)
    }
    
}
