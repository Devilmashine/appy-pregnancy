import CoreData

class CoreDataManager {

    static let shared = CoreDataManager()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "HappyPregnancy")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }

    // MARK: - Save

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Error saving context: \(error)")
            }
        }
    }

    // MARK: - Fetch

    func fetch<T: NSManagedObject>(_ objectType: T.Type) -> [T] {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)

        do {
            let fetchedObjects = try container.viewContext.fetch(fetchRequest)
            return fetchedObjects
        } catch {
            print("Error fetching \(entityName): \(error)")
            return []
        }
    }

    // MARK: - Delete

    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
        saveContext()
    }
}
