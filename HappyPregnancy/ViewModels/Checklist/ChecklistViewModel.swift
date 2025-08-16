import Foundation
import CoreData

class ChecklistViewModel: ObservableObject {

    @Published var checklistItems: [ChecklistItem] = []

    private let coreDataManager = CoreDataManager.shared

    init() {
        fetchChecklistItems()
    }

    func fetchChecklistItems() {
        let entities = coreDataManager.fetch(ChecklistItemEntity.self)
        self.checklistItems = entities.map { ChecklistItem(from: $0) }
    }

    func addChecklistItem(_ item: ChecklistItem) {
        let newItem = ChecklistItemEntity(context: coreDataManager.container.viewContext)
        newItem.id = item.id
        newItem.title = item.title
        newItem.isCompleted = item.isCompleted
        newItem.category = item.category.rawValue
        newItem.dueDate = item.dueDate
        newItem.notes = item.notes

        coreDataManager.saveContext()
        fetchChecklistItems()
    }

    func toggleChecklistItem(_ item: ChecklistItem) {
        let request = NSFetchRequest<ChecklistItemEntity>(entityName: "ChecklistItemEntity")
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)

        do {
            let results = try coreDataManager.container.viewContext.fetch(request)
            if let existingItem = results.first {
                existingItem.isCompleted.toggle()
                coreDataManager.saveContext()
                fetchChecklistItems()
            }
        } catch {
            print("Error toggling checklist item: \(error)")
        }
    }

    func deleteChecklistItem(at offsets: IndexSet) {
        for index in offsets {
            let item = checklistItems[index]
            let request = NSFetchRequest<ChecklistItemEntity>(entityName: "ChecklistItemEntity")
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)

            do {
                let results = try coreDataManager.container.viewContext.fetch(request)
                if let existingItem = results.first {
                    coreDataManager.delete(existingItem)
                }
            } catch {
                print("Error deleting checklist item: \(error)")
            }
        }
        fetchChecklistItems()
    }
}
