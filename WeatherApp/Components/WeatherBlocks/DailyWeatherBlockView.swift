import UIKit
import SnapKit

final class DailyWeatherBlockView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "FORECAST FOR 8 DAYS"
        label.font = AppTextStyle.currentLocationLabel.font
        label.textColor = AppColorManager.primary?.withAlphaComponent(0.52)
        return label
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(stackView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(12)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configure(with data: [DailyWeatherModel], weeklyMin: Double, weeklyMax: Double, cardColor: UIColor? = nil) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, day) in data.enumerated() {
            let row = DailyWeatherRowView()
            row.configure(
                with: day,
                weekMin: weeklyMin,
                weekMax: weeklyMax,
                isToday: index == 0
            )
            stackView.addArrangedSubview(row)
            
            if index < data.count - 1 {
                stackView.addArrangedSubview(createSeparator())
            }
        }
        
        if let color = cardColor {
            containerView.backgroundColor = color
        }
    }
    
    private func createSeparator() -> UIView {
        let container = UIView()
        let line = UIView()
        line.backgroundColor = .white.withAlphaComponent(0.2)
        container.addSubview(line)
        
        container.snp.makeConstraints { $0.height.equalTo(1) }
        line.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.height.equalTo(0.5)
        }
        return container
    }
}
