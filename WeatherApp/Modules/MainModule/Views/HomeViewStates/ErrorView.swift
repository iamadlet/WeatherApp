import UIKit
import SnapKit

final class ErrorView: UIView {
    
    var onRetryTapped: (() -> Void)?
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Something went wrong"
        label.font = AppTextStyle.title.font
        label.textColor = AppColorManager.primary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.setTitleColor(AppColorManager.background, for: .normal)
        button.backgroundColor = AppColorManager.primary
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(message: String) {
        messageLabel.text = message
    }
    
    @objc private func retryTapped() {
        onRetryTapped?()
    }
}

private extension ErrorView {
    
    func commonInit() {
        setupSubviews()
        setupConstraints()
    }
    
    func setupSubviews() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(retryButton)
    }
    
    func setupConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-80)
            make.size.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        retryButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(44)
        }
    }
}
