import UIKit
import SnapKit

final class WeatherInfoCardView: UIView {
    private let iconImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = AppColorManager.white?.withAlphaComponent(0.52)
        iv.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.currentLocationLabel.font
        label.textColor = AppColorManager.white?.withAlphaComponent(0.52)
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.title.font
        label.textColor = AppColorManager.primary
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.temperatureForecast.font
        label.textColor = AppColorManager.primary
        label.numberOfLines = 0
        return label
    }()
    
    private let footerLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.weatherCardFooter.font
        label.textColor = AppColorManager.primary
        label.numberOfLines = 0
        return label
    }()
    
    private let detailFooterLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.weatherCardFooter.font
        label.textColor = AppColorManager.primary?.withAlphaComponent(0.7)
        label.numberOfLines = 0
        return label
    }()
    
    private let customContentView = UIView()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = AppColorManager.background?.withAlphaComponent(0.5)
        layer.cornerRadius = 12
        clipsToBounds = true
        
        let headerStack = UIStackView(arrangedSubviews: [iconImage, titleLabel])
        headerStack.axis = .horizontal
        headerStack.spacing = 4
        headerStack.alignment = .center
        
        let mainStack = UIStackView(arrangedSubviews: [
            headerStack,
            valueLabel,
            descriptionLabel,
            customContentView,
            UIView(), // spacer
            footerLabel,
            detailFooterLabel
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 4
        mainStack.alignment = .leading
        
        addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        customContentView.isHidden = true
    }
    
    func configure(
        icon: String,
        title: String,
        value: String,
        description: String? = nil,
        footer: String? = nil,
        detailFooter: String? = nil,
        cardColor: UIColor? = nil
    ) {
        iconImage.image = UIImage(named: icon)
        titleLabel.text = title.uppercased()
        valueLabel.text = value
        
        descriptionLabel.text = description
        descriptionLabel.isHidden = description == nil
        
        footerLabel.text = footer
        footerLabel.isHidden = footer == nil
        
        detailFooterLabel.text = detailFooter
        detailFooterLabel.isHidden = detailFooter == nil
        
        if let color = cardColor {
            backgroundColor = color
        }
    }
    
    func addCustomContent(_ view: UIView) {
        customContentView.subviews.forEach { $0.removeFromSuperview() }
        customContentView.addSubview(view)
        view.snp.makeConstraints { $0.edges.equalToSuperview() }
        customContentView.isHidden = false
    }
}
