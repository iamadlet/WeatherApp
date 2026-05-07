import UIKit
import SnapKit

final class NotFoundView: UIView {
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Subviews
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 56, weight: .light)
        imageView.image = UIImage(named: "search")
        imageView.tintColor = UIColor.white.withAlphaComponent(0.5)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Nothing was found"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Please check your spelling or try a different query."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            iconImageView,
            titleLabel,
            subtitleLabel
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.setCustomSpacing(20, after: iconImageView)
        return stack
    }()
    
    // MARK: - Public
    /// Опционально можно передать запрос — он подставится в подзаголовок
    func configure(with query: String? = nil) {
        if let query = query, !query.isEmpty {
            subtitleLabel.text = "Nothing was found for the search '\(query)'. Check your spelling or try a different search."
        } else {
            subtitleLabel.text = "Please check your spelling or try a different query."
        }
    }
}

// MARK: - Setup
private extension NotFoundView {
    func commonInit() {
        setupSubviews()
        setupConstraints()
    }
    
    func setupSubviews() {
        addSubview(contentStack)
    }
    
    func setupConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(72)
        }
        
        contentStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.7) // чуть выше центра
            make.leading.greaterThanOrEqualToSuperview().offset(40)
            make.trailing.lessThanOrEqualToSuperview().offset(-40)
        }
    }
}
