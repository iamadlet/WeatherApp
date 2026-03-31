import UIKit
import CoreData

public final class CoreDataManager: NSObject {
    public static let shared = CoreDataManager()
    private override init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

// MARK: - Методы для работы с entity City
extension CoreDataManager {
    func createCity(from response: CityResponse) {
        let city = City(context: context)
        city.id = Int64(response.id)
        city.name = response.name
        city.lat = response.coord.lat
        city.lon = response.coord.lon
        city.country = response.country
        city.isSelected = false
        
        saveContext()
    }
    
    func fetchCities() -> [City] {
        let request: NSFetchRequest<City> = City.fetchRequest()
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch cities: \(error)")
            return []
        }
    }
    
    func deleteCity(_ city: City) {
        context.delete(city)
        saveContext()
    }
    
    func selectCity(_ selectedCity: City) {
        let cities = fetchCities()
        
        for city in cities {
            city.isSelected = (city.objectID == selectedCity.objectID)
        }
        
        saveContext()
    }
    
    func fetchSelectedCity() -> City? {
        let request: NSFetchRequest<City> = City.fetchRequest()
        request.predicate = NSPredicate(format: "isSelected == YES")
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Failed to fetch selected city: \(error)")
            return nil
        }
    }
    
}
