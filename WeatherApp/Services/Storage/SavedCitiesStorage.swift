import Foundation

protocol SavedCitiesStorageProtocol {
    func getAll() -> [SavedCity]
    func save(_ city: SavedCity)
    func remove(by id: String)
    func contains(id: String) -> Bool
    func clear()
    func saveCurrentLocation(_ city: SavedCity)
}

final class SavedCitiesStorage: SavedCitiesStorageProtocol {
    
    // MARK: - Constants
    private enum Keys {
        static let savedCities = "saved_cities_v1"
    }
    
    // MARK: - Dependencies
    private let userDefaults: UserDefaults
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // MARK: - Init
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
        
        // ISO 8601 для дат — стандарт и читается в JSON-вьюверах
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Public
    func getAll() -> [SavedCity] {
        guard let data = userDefaults.data(forKey: Keys.savedCities) else {
            return []
        }
        
        do {
            let cities = try decoder.decode([SavedCity].self, from: data)
            return cities.sorted { first, second in
                if first.isCurrentLocation { return true }   // текущий всегда первый
                if second.isCurrentLocation { return false }
                return first.addedAt < second.addedAt        // остальные по дате
            }
        } catch {
            print("Failed to decode saved cities: \(error)")
            return []
        }
    }
    
    func save(_ city: SavedCity) {
        var cities = getAll()
        
        // Если город уже есть — заменяем (чтобы обновить addedAt)
        cities.removeAll { $0.id == city.id }
        cities.append(city)
        
        persist(cities)
    }
    
    func remove(by id: String) {
        var cities = getAll()
        cities.removeAll { $0.id == id }
        persist(cities)
    }
    
    func contains(id: String) -> Bool {
        return getAll().contains { $0.id == id }
    }
    
    func clear() {
        userDefaults.removeObject(forKey: Keys.savedCities)
    }
    
    func saveCurrentLocation(_ city: SavedCity) {
        var cities = getAll()
        cities.removeAll { $0.isCurrentLocation }
        cities.insert(city, at: 0)
        persist(cities)
    }
    
    // MARK: - Private
    private func persist(_ cities: [SavedCity]) {
        do {
            let data = try encoder.encode(cities)
            userDefaults.set(data, forKey: Keys.savedCities)
        } catch {
            print("Failed to encode saved cities: \(error)")
        }
    }
}
