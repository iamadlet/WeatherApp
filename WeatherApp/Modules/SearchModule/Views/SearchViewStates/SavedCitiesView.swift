import UIKit
import SnapKit

final class SavedCitiesView: UIView {
    
    // MARK: - Callbacks
    var onCitySelected: ((SavedCityViewModel) -> Void)?
    var onCityDeleted: ((SavedCityViewModel) -> Void)?
    var onRefresh: (() -> Void)?
    
    // MARK: - State
    private var cities: [SavedCityViewModel] = []
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Subviews
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Weather"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 110
        table.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        table.showsVerticalScrollIndicator = false
        table.register(SavedCityCell.self, forCellReuseIdentifier: SavedCityCell.identifier)
        table.dataSource = self
        table.delegate = self
        return table
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
    
    // MARK: - Public
    func update(with cities: [SavedCityViewModel]) {
        self.cities = cities
        tableView.reloadData()
    }
    
    func updateCity(_ city: SavedCityViewModel) {
        print("updateCity called for \(city.name)")
        guard let index = cities.firstIndex(where: { $0.id == city.id }) else {
            print("City not found in cities array")
            return
        }
        cities[index] = city
        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

// MARK: - Setup
private extension SavedCitiesView {
    func commonInit() {
        backgroundColor = AppColorManager.citiesBackground
        setupSubviews()
        setupConstraints()
    }
    
    func setupSubviews() {
        addSubview(titleLabel)
        addSubview(tableView)
        tableView.refreshControl = refreshControl
    }
    
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(20)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDataSource
extension SavedCitiesView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SavedCityCell.identifier,
            for: indexPath
        ) as? SavedCityCell else {
            return UITableViewCell()
        }
        cell.configure(with: cities[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SavedCitiesView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onCitySelected?(cities[indexPath.row])
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let city = cities[indexPath.row]
        
        guard !city.isCurrentLocation else {
            return UISwipeActionsConfiguration(actions: [])
        }
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") {
            [weak self] _, _, completion in
            guard let self = self else { return }
            
            self.cities.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            self.onCityDeleted?(city)
            completion(true)
        }
        delete.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
