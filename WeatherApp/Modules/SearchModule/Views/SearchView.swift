import UIKit
import SnapKit

final class SearchView: UIView {
    var onRetryTapped: (() -> Void)?
    var onSearchTextChanged: ((String) -> Void)?
    var onSearchBeginEditing: (() -> Void)?
    var onSearchEndEditing: ((String) -> Void)?
    var onRefreshTapped: (() -> Void)?
    
    var onSavedCitySelected: ((SavedCityViewModel) -> Void)?
    var onSavedCityDeleted: ((SavedCityViewModel) -> Void)?
    var onSearchResultSelected: ((CitySuggestion) -> Void)?
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var savedCitiesView: SavedCitiesView = {
        let view = SavedCitiesView()
        view.backgroundColor = .clear
        view.isHidden = false // дефолтное состояние
        return view
    }()
    
    lazy var emptyQueryView: EmptyQueryView = {
        let view = EmptyQueryView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    lazy var loadingView: LoadingView = {
        let view = LoadingView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    lazy var resultsView: SearchResultsView = {
        let view = SearchResultsView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    lazy var notFoundView: NotFoundView = {
        let view = NotFoundView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    lazy var errorView: ErrorView = {
        let view = ErrorView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    lazy var searchField: CustomSearchField = {
        let field = CustomSearchField()
        field.delegate = self
        field.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        return field
    }()
    
    // MARK: - State views (все, кроме searchField)
    private lazy var stateViews: [UIView] = [
        savedCitiesView,
        emptyQueryView,
        loadingView,
        resultsView,
        notFoundView,
        errorView
    ]
    
    func showSavedCities(_ cities: [SavedCityViewModel]) {
        hideAllStates()
        savedCitiesView.update(with: cities)
        savedCitiesView.isHidden = false
        bringSubviewToFront(savedCitiesView)
        bringSubviewToFront(searchField)
        searchField.text = ""
    }
    
    func showEmptyQuery() {
        hideAllStates()
        emptyQueryView.isHidden = false
        bringSubviewToFront(emptyQueryView)
        bringSubviewToFront(searchField)
    }
    
    func showLoading() {
        hideAllStates()
        loadingView.isHidden = false
        bringSubviewToFront(loadingView)
        bringSubviewToFront(searchField)
    }
    
    func showResults() {
        hideAllStates()
        resultsView.isHidden = false
        bringSubviewToFront(resultsView)
        bringSubviewToFront(searchField)
    }
    
    func showNotFound() {
        hideAllStates()
        notFoundView.isHidden = false
        bringSubviewToFront(notFoundView)
        bringSubviewToFront(searchField)
    }
    
    func showError() {
        hideAllStates()
        errorView.isHidden = false
        bringSubviewToFront(errorView)
        bringSubviewToFront(searchField)
    }
    
    private func hideAllStates() {
        stateViews.forEach { $0.isHidden = true }
    }
    
    @objc private func searchTextChanged() {
        onSearchTextChanged?(searchField.text ?? "")
    }
}


private extension SearchView {
    func commonInit() {
        backgroundColor = AppColorManager.citiesBackground
        setupSubviews()
        setupConstraints()
        setupCallbacks()
    }
    
    func setupSubviews() {
        addSubview(backgroundImageView)
        addSubview(savedCitiesView)
        addSubview(emptyQueryView)
        addSubview(loadingView)
        addSubview(resultsView)
        addSubview(notFoundView)
        addSubview(errorView)
        addSubview(searchField)
    }
    
    func setupConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Все state views на весь экран до searchField
        stateViews.forEach { view in
            view.snp.makeConstraints { make in
                make.top.equalTo(safeAreaLayoutGuide)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(searchField.snp.top).offset(-16)
            }
        }
        
        searchField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(44)
        }
    }
    
    func setupCallbacks() {
        errorView.onRetryTapped = { [weak self] in
            self?.onRetryTapped?()
        }
        
        savedCitiesView.onCitySelected = { [weak self] savedCity in
            self?.onSavedCitySelected?(savedCity)
        }
        
        savedCitiesView.onCityDeleted = { [weak self] city in
            self?.onSavedCityDeleted?(city)
        }
        
        resultsView.onCitySelected = { [weak self] city in
            self?.onSearchResultSelected?(city)
        }
        
        savedCitiesView.onRefresh = { [weak self] in
            self?.onRefreshTapped?()
        }
    }
}

extension SearchView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        onSearchBeginEditing?()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        onSearchEndEditing?(textField.text ?? "")
    }
}
