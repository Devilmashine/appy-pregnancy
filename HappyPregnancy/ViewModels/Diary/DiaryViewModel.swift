import Foundation
import CoreData

class DiaryViewModel: ObservableObject {

    @Published var diaryEntries: [DiaryEntry] = []

    private let coreDataManager = CoreDataManager.shared

    init() {
        fetchDiaryEntries()
    }

    func fetchDiaryEntries() {
        let entities = coreDataManager.fetch(DiaryEntryEntity.self)
        self.diaryEntries = entities.map { DiaryEntry(from: $0) }
    }

    func addDiaryEntry(_ entry: DiaryEntry) {
        let newEntry = DiaryEntryEntity(context: coreDataManager.container.viewContext)
        newEntry.id = entry.id
        newEntry.date = entry.date
        newEntry.mood = Int16(entry.mood)
        newEntry.symptoms = entry.symptoms
        newEntry.notes = entry.notes
        newEntry.photos = entry.photos

        coreDataManager.saveContext()
        fetchDiaryEntries()
    }

    func updateDiaryEntry(_ entry: DiaryEntry) {
        let request = NSFetchRequest<DiaryEntryEntity>(entityName: "DiaryEntryEntity")
        request.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)

        do {
            let results = try coreDataManager.container.viewContext.fetch(request)
            if let existingEntry = results.first {
                existingEntry.date = entry.date
                existingEntry.mood = Int16(entry.mood)
                existingEntry.symptoms = entry.symptoms
                existingEntry.notes = entry.notes
                existingEntry.photos = entry.photos

                coreDataManager.saveContext()
                fetchDiaryEntries()
            }
        } catch {
            print("Error updating diary entry: \(error)")
        }
    }

    func deleteDiaryEntry(at offsets: IndexSet) {
        for index in offsets {
            let entry = diaryEntries[index]
            let request = NSFetchRequest<DiaryEntryEntity>(entityName: "DiaryEntryEntity")
            request.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)

            do {
                let results = try coreDataManager.container.viewContext.fetch(request)
                if let existingEntry = results.first {
                    coreDataManager.delete(existingEntry)
                }
            } catch {
                print("Error deleting diary entry: \(error)")
            }
        }
        fetchDiaryEntries()
    }
}
