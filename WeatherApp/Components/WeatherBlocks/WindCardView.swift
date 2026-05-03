import UIKit
import SnapKit

final class WindCardView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        return sv
    }()
    
    private func setupUI() {
        backgroundColor = AppColorManager.background?.withAlphaComponent(0.5)
        layer.cornerRadius = 12
        clipsToBounds = true
        
        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.spacing = 4
        headerStack.alignment = .center
        
        let iconImage = UIImageView()
        iconImage.image = UIImage(named: "wind")
        iconImage.contentMode = .scaleToFill
        
        let titleLabel = UILabel()
        titleLabel.text = "WIND"
        titleLabel.font = AppTextStyle.currentLocationLabel.font
        titleLabel.textColor = AppColorManager.primary?.withAlphaComponent(0.52)
        
        headerStack.addArrangedSubview(iconImage)
        headerStack.addArrangedSubview(titleLabel)
        
        addSubview(headerStack)
        addSubview(stackView)
        
        headerStack.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(12)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(headerStack.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configure(wind: String, gusts: String, direction: String, cardColor: UIColor? = nil) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let rows: [(String, String)] = [
            ("Wind", wind),
            ("Gusts", gusts),
            ("Direction", direction)
        ]
        
        for (index, row) in rows.enumerated() {
            let rowView = createRow(title: row.0, value: row.1)
            stackView.addArrangedSubview(rowView)
            
            if index < rows.count - 1 {
                stackView.addArrangedSubview(createSeparator())
            }
        }
        
        if let color = cardColor {
            backgroundColor = color
        }
    }
    
    private func createRow(title: String, value: String) -> UIView {
        let container = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppTextStyle.subtitle.font
        titleLabel.textColor = AppColorManager.primary
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = AppTextStyle.temperatureForecast.font
        valueLabel.textColor = AppColorManager.primary?.withAlphaComponent(0.52)
        valueLabel.textAlignment = .right
        
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
        }
        
        container.snp.makeConstraints { $0.height.equalTo(44) }
        return container
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
