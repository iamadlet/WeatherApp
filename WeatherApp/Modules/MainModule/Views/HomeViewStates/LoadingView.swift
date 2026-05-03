import UIKit
import SnapKit

final class LoadingView: UIView {
    private let activityIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.startAnimating()
        return indicator
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.font = AppTextStyle.title.font
        label.textColor = AppColorManager.primary
        label.textAlignment = .center
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension LoadingView {
    func commonInit() {
        setupSubviews()
        setupConstraints()
    }
    
    func setupSubviews() {
        addSubview(activityIndicatorView)
        addSubview(messageLabel)
    }
    
    func setupConstraints() {
        activityIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(activityIndicatorView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
    }
}
