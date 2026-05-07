import Foundation

protocol SavedCitiesServiceProtocol: AnyObject {
    var cities: [SavedCity] { get }
    func add(_ city: City)
    func remove(by id: String)
    func isSaved(id: String) -> Bool
    
    // Подписка на изменения
    func subscribe(_ observer: AnyObject, handler: @escaping ([SavedCity]) -> Void)
    func unsubscribe(_ observer: AnyObject)
    func updateCurrentLocation(_ city: SavedCity)
}

final class SavedCitiesService: SavedCitiesServiceProtocol {
    static let shared = SavedCitiesService()
    
    // MARK: - Dependencies
    private let storage: SavedCitiesStorageProtocol
    
    // MARK: - State
    private(set) var cities: [SavedCity] = []
    
    // MARK: - Observers
    private struct Observer {
        weak var object: AnyObject?
        let handler: ([SavedCity]) -> Void
    }
    private var observers: [Observer] = []
    
    // MARK: - Init
    init(storage: SavedCitiesStorageProtocol = SavedCitiesStorage()) {
        self.storage = storage
        self.cities = storage.getAll()
    }
    
    // MARK: - Public
    func add(_ city: City) {
        let savedCity = SavedCity(city: city)
        storage.save(savedCity)
        reload()
    }
    
    func remove(by id: String) {
        print("🗑 remove called for id: \(id)")
        print("🗑 cities before remove: \(cities.map { $0.name })")
        guard let city = cities.first(where: { $0.id == id }), !city.isCurrentLocation else {
            print("🔴 city not found or isCurrentLocation — skipping remove")
            return
        }
        storage.remove(by: id)
        reload()
        print("✅ cities after remove: \(cities.map { $0.name })")
    }
    
    func isSaved(id: String) -> Bool {
        cities.contains { $0.id == id }
    }
    
    // MARK: - Subscriptions
    func subscribe(_ observer: AnyObject, handler: @escaping ([SavedCity]) -> Void) {
        observers.append(Observer(object: observer, handler: handler))
        // Сразу даём текущее состояние
        handler(cities)
    }
    
    func unsubscribe(_ observer: AnyObject) {
        observers.removeAll { $0.object === observer }
    }
    
    // MARK: - Private
    private func reload() {
        cities = storage.getAll()
        notifyObservers()
    }
    
    private func notifyObservers() {
        // Чистим мёртвых обсерверов
        observers.removeAll { $0.object == nil }
        observers.forEach { $0.handler(cities) }
    }
    
    func updateCurrentLocation(_ city: SavedCity) {
        storage.saveCurrentLocation(city)
        reload()
    }
    
    func getCities() -> [SavedCity] {
        return cities
    }
}
