import UIKit

protocol SearchViewProtocol: AnyObject {
    func showSavedCities(_ cities: [SavedCityViewModel])
    func showEmptyQuery()
    func showLoading()
    func showResults(_ suggestions: [CitySuggestion])
    func showNotFound()
    func showError()

    func updateSavedCity(_ city: SavedCityViewModel)
    func stopRefreshing()
}

import UIKit

final class SearchViewController: UIViewController {
    private let presenter: SearchPresenterProtocol
    
    private lazy var searchView = SearchView()
    
    init(presenter: SearchPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = searchView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupCallbacks()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    private func setupCallbacks() {
        searchView.onRetryTapped = { [weak self] in
            self?.presenter.didTapRetry()
        }
        
        searchView.onSearchTextChanged = { [weak self] text in
            self?.presenter.searchQueryChanged(text)
        }
        
        searchView.onSearchBeginEditing = { [weak self] in
            self?.presenter.searchFieldDidBeginEditing()
        }
        
        searchView.onSearchEndEditing = { [weak self] text in
            self?.presenter.searchFieldDidEndEditing(text: text)
        }
        
        searchView.onSavedCitySelected = { [weak self] city in
            self?.presenter.didSelectSavedCity(city)
        }
        
        searchView.onSavedCityDeleted = { [weak self] city in
            self?.presenter.didTapDeleteSavedCity(city)
        }
        
        searchView.onSearchResultSelected = { [weak self] suggestion in
            self?.presenter.didSelectSuggestion(suggestion)
        }
        
        searchView.onRefreshTapped = { [weak self] in
            self?.presenter.didPullToRefresh()
        }
    }
}

extension SearchViewController: SearchViewProtocol {
    func showSavedCities(_ cities: [SavedCityViewModel]) {
        searchView.showSavedCities(cities)
    }
    
    func showEmptyQuery() {
        searchView.showEmptyQuery()
    }
    
    func showLoading() {
        searchView.showLoading()
    }
    
    func showResults(_ suggestions: [CitySuggestion]) {
        searchView.resultsView.configure(with: suggestions)
        searchView.showResults()
    }
    
    func showNotFound() {
        searchView.showNotFound()
    }
    
    func showError() {
        searchView.showError()
    }
    
    func updateSavedCity(_ city: SavedCityViewModel) {
        searchView.savedCitiesView.updateCity(city)
    }
    
    func stopRefreshing() {
        searchView.savedCitiesView.endRefreshing()
    }
}
