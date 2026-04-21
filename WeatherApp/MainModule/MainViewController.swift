import UIKit

protocol MainViewProtocol: AnyObject {
    func showWeather()
    
    func showError()
    
    func showLoading()
    func reloadData()
    func setBackground(_ background: WeatherBackground)
}

final class MainViewController: UIViewController {
    
    
    private let presenter: MainPresenterProtocol
    
    private lazy var mainView = MainView()
    
    init(presenter: MainPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupCallBacks()
        
        print("WeatherViewController loaded")
        presenter.viewDidLoad()
    }
    
    private func setupCollectionView() {
        mainView.weatherView.collectionView.delegate = self
        mainView.weatherView.collectionView.dataSource = self
    }
    
    private func setupCallBacks() {
        mainView.onRetryTapped = { [weak self] in
            self?.presenter.didTapRetry()
        }
    }
}

extension MainViewController: MainViewProtocol {
    func setBackground(_ background: WeatherBackground) {
        mainView.setBackground(background)
    }
    
    func showWeather() {
        mainView.showWeather()
    }
    
    func showError() {
        mainView.showError()
    }
    
    func showLoading() {
        mainView.showLoading()
    }
    
    func reloadData() {
        mainView.showWeather()
        mainView.reloadData()
    }
}

extension MainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presenter.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = presenter.sectionType(for: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch sectionType {
        case .current:
            return configureCurrentCell(collectionView, at: indexPath)
        case .hourly:
            return configureHourlyCell(collectionView, at: indexPath)
        case .daily:
            return configureDailyCell(collectionView, at: indexPath)
        }
    }
    
    
}

extension MainViewController: UICollectionViewDelegate {
    
}


private extension MainViewController {
    func configureCurrentCell(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CurrentWeatherCell.identifier,
            for: indexPath
        ) as? CurrentWeatherCell,
        let current = presenter.currentWeather() else {
            return UICollectionViewCell()
        }
        
        cell.configure(
            city: presenter.cityName(),
            current: current,
            todayDaily: presenter.todayDailyWeather()
        )
        return cell
    }
    
    func configureHourlyCell(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HourlyWeatherCell.identifier,
            for: indexPath
        ) as? HourlyWeatherCell,
        let model = presenter.hourlyWeather(at: indexPath.item) else {
            return UICollectionViewCell()
        }
        
        let isNow = presenter.isFirstItem(indexPath.item)
        cell.configure(with: model, isNow: isNow)
        return cell
    }
    
    func configureDailyCell(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DailyWeatherCell.identifier,
            for: indexPath
        ) as? DailyWeatherCell,
        let model = presenter.dailyWeather(at: indexPath.item) else {
            return UICollectionViewCell()
        }
        
        let isToday = presenter.isFirstItem(indexPath.item)
        let tempRange = presenter.weekTemperatureRange()
        
        cell.configure(
            with: model,
            weekMin: tempRange.min,
            weekMax: tempRange.max,
            isToday: isToday
        )
        return cell
    }
}
