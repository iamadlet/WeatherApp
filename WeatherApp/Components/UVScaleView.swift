import UIKit
import SnapKit

final class UVScaleView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private let gradientLayer = CAGradientLayer()
    private let indicator = UIView()
    
    private var value: CGFloat = 0
    
    private func setupUI() {
        layer.cornerRadius = 3
        clipsToBounds = true
        
        gradientLayer.colors = [
            UIColor.green.cgColor,
            UIColor.yellow.cgColor,
            UIColor.orange.cgColor,
            UIColor.red.cgColor,
            UIColor.purple.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
        
        indicator.backgroundColor = .white
        indicator.layer.cornerRadius = 4
        indicator.layer.borderWidth = 1.5
        indicator.layer.borderColor = UIColor.white.cgColor
        addSubview(indicator)
        
        snp.makeConstraints { $0.height.equalTo(6) }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        
        let maxUV: CGFloat = 11
        let position = min(value / maxUV, 1.0) * bounds.width
        indicator.frame = CGRect(x: position - 4, y: -1, width: 8, height: 8)
    }
    
    func configure(uvIndex: CGFloat) {
        self.value = uvIndex
        setNeedsLayout()
    }
}
