import UIKit
import SnapKit

final class WeatherScrollView: UIView {
    var onRefresh: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = .white
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    @objc private func handleRefresh() {
        onRefresh?()
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
    let currentWeatherView = CurrentWeatherBlockView()
    let hourlyWeatherView = HourlyWeatherBlockView()
    let dailyWeatherView = DailyWeatherBlockView()
    let weatherDetailsGridView = WeatherDetailsGridView()
    
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.refreshControl = refreshControl
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        stackView.addArrangedSubview(currentWeatherView)
        stackView.addArrangedSubview(hourlyWeatherView)
        stackView.addArrangedSubview(dailyWeatherView)
        stackView.addArrangedSubview(weatherDetailsGridView)
    }
}
