import UIKit
import SnapKit

final class SearchResultsView: UIView {
    
    // MARK: - Callbacks
    var onCitySelected: ((CitySuggestion) -> Void)?
    
    // MARK: - State
    private var cities: [CitySuggestion] = []
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Subviews
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 64
        table.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        table.keyboardDismissMode = .onDrag
        table.showsVerticalScrollIndicator = false
        table.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.identifier)
        table.dataSource = self
        table.delegate = self
        return table
    }()
    
    // MARK: - Public
    func update(with cities: [CitySuggestion]) {
        self.cities = cities
        tableView.reloadData()
        // Прокрутка наверх при новых результатах
        if !cities.isEmpty {
            tableView.setContentOffset(.zero, animated: false)
        }
    }
    
    func configure(with cities: [CitySuggestion]) {
        self.cities = cities
        tableView.reloadData()
        
        if !cities.isEmpty {
            tableView.setContentOffset(.zero, animated: false)
        }
    }
}

// MARK: - Setup
private extension SearchResultsView {
    func commonInit() {
        setupSubviews()
        setupConstraints()
    }
    
    func setupSubviews() {
        addSubview(tableView)
    }
    
    func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDataSource
extension SearchResultsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchResultCell.identifier,
            for: indexPath
        ) as? SearchResultCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: cities[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SearchResultsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let city = cities[indexPath.row]
        onCitySelected?(city)
    }
}
