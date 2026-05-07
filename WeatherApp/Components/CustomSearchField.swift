import UIKit

class CustomSearchField: UITextField {
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        setupIcon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAppearance()
        setupIcon()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        layer.cornerRadius = bounds.height / 2
    }
    
    private func setupAppearance() {
        let baseColor = AppColorManager.searchFieldBackground
        
        gradientLayer.colors = [
            baseColor?.withAlphaComponent(0.0).cgColor,
            baseColor?.withAlphaComponent(0.52).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.insertSublayer(gradientLayer, at: 0)
        
        layer.borderWidth = 1
        layer.borderColor = AppColorManager.white?.withAlphaComponent(0.52).cgColor
        layer.masksToBounds = true
        
        textColor = AppColorManager.primary
        font = AppTextStyle.weatherCardFooter.font
        tintColor = AppColorManager.primary
        
        attributedPlaceholder = NSAttributedString(
            string: "Search city or airport",
            attributes: [
                .foregroundColor: AppColorManager.primary?.withAlphaComponent(0.52),
                .font: AppTextStyle.weatherCardFooter.font
            ]
        )
    }
    
    private func setupIcon() {
        let icon = UIImageView(image: UIImage(named: "search"))
        icon.tintColor = AppColorManager.white
        icon.contentMode = .scaleAspectFit
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 20))
        icon.frame = CGRect(x: 16, y: 0, width: 20, height: 20)
        container.addSubview(icon)
        
        leftView = container
        leftViewMode = .always
    }
}
