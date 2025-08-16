import Foundation
import CoreData

class KicksCounterViewModel: ObservableObject {

    @Published var kicksSessions: [KicksSession] = []

    private let coreDataManager = CoreDataManager.shared

    init() {
        fetchKicksSessions()
    }

    func fetchKicksSessions() {
        let entities = coreDataManager.fetch(KicksSessionEntity.self)
        self.kicksSessions = entities.map { KicksSession(from: $0) }
    }

    func addKicksSession(_ session: KicksSession) {
        let newSession = KicksSessionEntity(context: coreDataManager.container.viewContext)
        newSession.id = session.id
        newSession.date = session.date
        newSession.duration = session.duration
        newSession.kicksCount = Int32(session.kicksCount)
        newSession.notes = session.notes

        coreDataManager.saveContext()
        fetchKicksSessions()
    }

    func getKicksForToday() -> [KicksSession] {
        let calendar = Calendar.current
        return kicksSessions.filter { calendar.isDateInToday($0.date) }
    }

    func deleteKicksSession(at offsets: IndexSet) {
        for index in offsets {
            let session = kicksSessions[index]
            let request = NSFetchRequest<KicksSessionEntity>(entityName: "KicksSessionEntity")
            request.predicate = NSPredicate(format: "id == %@", session.id as CVarArg)

            do {
                let results = try coreDataManager.container.viewContext.fetch(request)
                if let existingSession = results.first {
                    coreDataManager.delete(existingSession)
                }
            } catch {
                print("Error deleting kicks session: \(error)")
            }
        }
        fetchKicksSessions()
    }
}
