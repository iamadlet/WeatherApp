import UIKit
import SnapKit

final class TemperatureBarView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBarPosition()
    }
    
    private var colorBarLeadingConstraint: Constraint?
    private var colorBarTrailingConstraint: Constraint?
    
    private var weekMin: Double = 0
    private var weekMax: Double = 0
    
    private var dayMin: Double = 0
    private var dayMax: Double = 0
    
    private let backgroundBar: UIView = {
        let view = UIView()
        view.backgroundColor = AppColorManager.black?.withAlphaComponent(0.08)
        view.layer.cornerRadius = 4
        return view
    }()
    
    private let colorBar: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.backgroundColor = AppColorManager.temperatureBarMint
        view.clipsToBounds = true
        return view
    }()
    
    private func setupUI() {
        clipsToBounds = true
        
        addSubview(backgroundBar)
        addSubview(colorBar)
        
        colorBar.isHidden = true
        
        backgroundBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(4)
        }
        
        colorBar.snp.makeConstraints { make in
            colorBarLeadingConstraint = make.leading.equalToSuperview().constraint
            colorBarTrailingConstraint = make.trailing.equalToSuperview().constraint
            make.centerY.equalToSuperview()
            make.height.equalTo(4)
        }
    }
    
    func configure(weekMin: Double, weekMax: Double, dayMin: Double, dayMax: Double) {
        self.weekMax = weekMax
        self.weekMin = weekMin
        self.dayMax = dayMax
        self.dayMin = dayMin
        
        colorBar.isHidden = false
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func updateBarPosition() {
        let totalRange = weekMax - weekMin
        
        guard totalRange > 0, bounds.width > 0 else { return }
        
        let minPosition = (dayMin - weekMin) / totalRange
        let maxPosition = (dayMax - weekMin) / totalRange
        
        let totalWidth = bounds.width
        let leadingOffset = totalWidth * minPosition
        let trailingOffset = totalWidth * (1 - maxPosition)
        
        colorBarLeadingConstraint?.update(offset: leadingOffset)
        colorBarTrailingConstraint?.update(offset: -trailingOffset)
    }
    
    func reset() {
        colorBarLeadingConstraint?.update(offset: 0)
        colorBarTrailingConstraint?.update(offset: 0)
        colorBar.backgroundColor = AppColorManager.temperatureBarMint
    }
}
