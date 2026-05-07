import Foundation

protocol SearchPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapRetry()
    func viewWillAppear()
    
    func searchQueryChanged(_ query: String)
    func searchFieldDidBeginEditing()
    func searchFieldDidEndEditing(text: String)
    
    func didSelectSuggestion(_ suggestion: CitySuggestion)
    func didSelectSavedCity(_ city: SavedCityViewModel)
    func didTapDeleteSavedCity(_ city: SavedCityViewModel)
    func didPullToRefresh()
}

final class SearchPresenter: SearchPresenterProtocol {
    weak var view: SearchViewProtocol?
    
    private let router: SearchRouterProtocol
    
    private let citySearchService: CitySearchServiceProtocol
    private let weatherService: WeatherServiceProtocol
    private let savedCitiesService: SavedCitiesServiceProtocol
    private let executor: CancellableExecutorProtocol
    
    private var lastQuery: String = ""
    private var suggestions: [CitySuggestion] = []
    private var savedCities: [SavedCityViewModel] = []
    
    init(router: SearchRouterProtocol,
         citySearchService: CitySearchServiceProtocol,
         weatherService: WeatherServiceProtocol,
         savedCitiesService: SavedCitiesServiceProtocol,
         executor: CancellableExecutorProtocol) {
        self.router = router
        self.citySearchService = citySearchService
        self.weatherService = weatherService
        self.savedCitiesService = savedCitiesService
        self.executor = executor
    }
    
    deinit {
        savedCitiesService.unsubscribe(self)
    }
    
    // MARK: - Public
    func viewDidLoad() {
        savedCitiesService.subscribe(self) { [weak self] cities in
            DispatchQueue.main.async {
                self?.handleSavedCitiesUpdate(cities)
            }
        }
    }
    
    func viewWillAppear() {
        print("✅ viewWillAppear called, savedCities count: \(savedCities.count)")
        print("✅ lastQuery: '\(lastQuery)'")
        lastQuery = ""
        view?.showSavedCities(savedCities)
    }
    
    func didTapRetry() {
        if !lastQuery.isEmpty {
            performSearch(query: lastQuery)
        } else {
            loadSavedCitiesWeather()
        }
    }
    
    func searchFieldDidBeginEditing() {
        if lastQuery.isEmpty {
            view?.showEmptyQuery()
        }
    }
    
    func searchFieldDidEndEditing(text: String) {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            view?.showSavedCities(savedCities)
        }
    }
    
    func searchQueryChanged(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        lastQuery = trimmed
        
        executor.execute(delay: .milliseconds(400)) { [weak self] token in
            guard let self = self else { return }
            guard !token.isCancelled else { return }
            
            self.performSearch(query: trimmed)
        }
    }
    
    func didSelectSuggestion(_ suggestion: CitySuggestion) {
        view?.showLoading()
        
        citySearchService.resolveCoordinates(for: suggestion) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let city):
                    self.view?.showSavedCities(self.savedCities)
                    self.router.openCityPreview(for: city)
                case .failure(let error):
                    print("Resolve error: \(error)")
                    self.view?.showError()
                }
            }
        }
    }
    
    func didSelectSavedCity(_ city: SavedCityViewModel) {
        router.openMainModule(for: city)
    }
    
    func didTapDeleteSavedCity(_ city: SavedCityViewModel) {
        print("didTapDeleteSavedCity called for: \(city.name), id: \(city.id)")
        guard !city.isCurrentLocation else { return }
        savedCitiesService.remove(by: city.id)
    }
    
    func cityPreviewDismissed() {
        lastQuery = ""
        view?.showSavedCities(savedCities)
    }
    
    func didPullToRefresh() {
        savedCities = savedCities.map { city in
            var updated = city
            updated.weather = nil
            return updated
        }
        
        let group = DispatchGroup()
        
        for city in savedCities {
            group.enter()
            fetchWeatherWithCompletion(for: city) {
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.view?.stopRefreshing()
        }
    }
    
    private func fetchWeatherWithCompletion(for city: SavedCityViewModel, completion: @escaping () -> Void) {
        let request = ForecastRequest(
            lat: city.coordinates.latitude,
            lon: city.coordinates.longitude,
            appid: Secrets.apiKey
        )
        
        weatherService.fetchWeather(request: request) { [weak self] result in
            DispatchQueue.main.async {
                defer { completion() }
                guard let self = self else { return }
                guard let index = self.savedCities.firstIndex(where: { $0.id == city.id }) else { return }
                
                switch result {
                case .success(let weather):
                    let weatherModel = SavedCityWeather(
                        temperature: weather.current.temperature,
                        description: weather.daily.first?.main.description ?? "",
                        minTemp: weather.daily.first?.minTemperature ?? 0,
                        maxTemp: weather.daily.first?.maxTemperature ?? 0,
                        weatherId: weather.current.weatherId,
                        timezone: weather.timezone
                    )
                    self.savedCities[index].weather = weatherModel
                    
                    if self.lastQuery.isEmpty {
                        self.view?.updateSavedCity(self.savedCities[index])
                    }
                    
                case .failure(let error):
                    print("Weather error for \(city.name): \(error)")
                }
            }
        }
    }
}

// MARK: - Private (Search)

private extension SearchPresenter {
    
    func performSearch(query: String) {
        guard !query.isEmpty else {
            DispatchQueue.main.async {
                self.suggestions = []
                self.view?.showSavedCities(self.savedCities)
            }
            return
        }
        
        DispatchQueue.main.async {
            self.view?.showLoading()
        }
        
        citySearchService.searchCities(query: query) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard query == self.lastQuery else { return }
                
                switch result {
                case .success(let suggestions):
                    self.suggestions = suggestions
                    
                    if suggestions.isEmpty {
                        self.view?.showNotFound()
                    } else {
                        self.view?.showResults(suggestions)
                    }
                    
                case .failure(let error):
                    print("Error: \(error)")
                    self.view?.showError()
                }
            }
        }
    }
}

// MARK: - Private (Saved cities)

private extension SearchPresenter {
    
    func handleSavedCitiesUpdate(_ cities: [SavedCity]) {
        print("✅ handleSavedCitiesUpdate called, cities count: \(cities.count)")
        let oldWeatherByID = Dictionary(
            uniqueKeysWithValues: savedCities.map { ($0.id, $0.weather) }
        )
        
        savedCities = cities.map { city in
            SavedCityViewModel(
                id: city.id,
                name: city.name,
                coordinates: Coordinates(latitude: city.latitude, longitude: city.longitude),
                weather: oldWeatherByID[city.id] ?? nil,
                isCurrentLocation: city.isCurrentLocation
            )
        }
        
        if lastQuery.isEmpty {
            view?.showSavedCities(savedCities)
        }
        
        loadSavedCitiesWeather()
    }
    
    func loadSavedCitiesWeather() {
        for city in savedCities where city.weather == nil {
            fetchWeather(for: city)
        }
    }
    
    func fetchWeather(for city: SavedCityViewModel) {
        let request = ForecastRequest(
            lat: city.coordinates.latitude,
            lon: city.coordinates.longitude,
            appid: Secrets.apiKey
        )
        
        weatherService.fetchWeather(request: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard let index = self.savedCities.firstIndex(where: { $0.id == city.id }) else {
                    return
                }
                
                switch result {
                case .success(let weather):
                    let weatherModel = SavedCityWeather(
                        temperature: weather.current.temperature,
                        description: weather.daily.first?.main.description ?? "",
                        minTemp: weather.daily.first?.minTemperature ?? 0,
                        maxTemp: weather.daily.first?.maxTemperature ?? 0,
                        weatherId: weather.current.weatherId,
                        timezone: weather.timezone
                    )
                    self.savedCities[index].weather = weatherModel
                    print("Weather loaded for \(city.name): \(weatherModel.temperature)°")
                    
                    if self.lastQuery.isEmpty {
                        print("Calling updateSavedCity")
                        self.view?.updateSavedCity(self.savedCities[index])
                    }
                    
                case .failure(let error):
                    print("Weather error for \(city.name): \(error)")
                }
            }
        }
    }
}
