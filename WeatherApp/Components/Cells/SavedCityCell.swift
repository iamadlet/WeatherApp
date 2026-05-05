import UIKit
import SnapKit

final class SavedCityCell: UITableViewCell {
    
    // MARK: - Identifier
    static let identifier = "SavedCityCell"
    
    // MARK: - Subviews
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        view.clipsToBounds = true
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        return label
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 44, weight: .light)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private let highLowLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(with city: SavedCityViewModel) {
        nameLabel.text = city.name
        subtitleLabel.text = formattedTime(for: city)
        
        if let weather = city.weather {
            temperatureLabel.text = "\(Int(weather.temperature.rounded()))°"
            conditionLabel.text = weather.description.capitalized
            highLowLabel.text = "H:\(Int(weather.maxTemp.rounded()))°, L:\(Int(weather.minTemp.rounded()))°"
        } else {
            // Погода ещё грузится
            temperatureLabel.text = "—°"
            conditionLabel.text = "—"
            highLowLabel.text = "H:—° L:—°"
        }
    }
    
    // MARK: - Highlight
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.containerView.transform = highlighted
                ? CGAffineTransform(scaleX: 0.98, y: 0.98)
                : .identity
        }
    }
    
    // MARK: - Private
    private func formattedTime(for city: SavedCityViewModel) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let timezone = city.weather?.timezone {
            let tz = TimeZone(identifier: timezone)
            formatter.timeZone = tz
        }
        return formatter.string(from: Date())
    }
}

// MARK: - Setup
private extension SavedCityCell {
    func commonInit() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .clear
        
        setupSubviews()
        setupConstraints()
    }
    
    func setupSubviews() {
        contentView.addSubview(containerView)
        [nameLabel, subtitleLabel, temperatureLabel, conditionLabel, highLowLabel]
            .forEach { containerView.addSubview($0) }
    }
    
    func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(105)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualTo(temperatureLabel.snp.leading).offset(-12)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.leading.equalTo(nameLabel)
        }
        
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        conditionLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14)
            make.leading.equalToSuperview().offset(16)
        }
        
        highLowLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14)
            make.trailing.equalToSuperview().offset(-16)
            make.leading.greaterThanOrEqualTo(conditionLabel.snp.trailing).offset(8)
        }
    }
}
