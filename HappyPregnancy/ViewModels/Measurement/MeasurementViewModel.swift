import Foundation
import CoreData

class MeasurementViewModel: ObservableObject {

    @Published var measurements: [WeightMeasurement] = []

    private let coreDataManager = CoreDataManager.shared

    init() {
        fetchMeasurements()
    }

    func fetchMeasurements() {
        let entities = coreDataManager.fetch(MeasurementEntity.self)
        self.measurements = entities.map { WeightMeasurement(from: $0) }
    }

    func addMeasurement(_ measurement: WeightMeasurement) {
        let newMeasurement = MeasurementEntity(context: coreDataManager.container.viewContext)
        newMeasurement.id = measurement.id
        newMeasurement.date = measurement.date
        newMeasurement.weight = measurement.weight
        newMeasurement.bellyCircumference = measurement.bellyCircumference
        newMeasurement.notes = measurement.notes

        coreDataManager.saveContext()
        fetchMeasurements()
    }

    func deleteMeasurement(at offsets: IndexSet) {
        for index in offsets {
            let measurement = measurements[index]
            let request = NSFetchRequest<MeasurementEntity>(entityName: "MeasurementEntity")
            request.predicate = NSPredicate(format: "id == %@", measurement.id as CVarArg)

            do {
                let results = try coreDataManager.container.viewContext.fetch(request)
                if let existingMeasurement = results.first {
                    coreDataManager.delete(existingMeasurement)
                }
            } catch {
                print("Error deleting measurement: \(error)")
            }
        }
        fetchMeasurements()
    }

    func getLatestMeasurement() -> WeightMeasurement? {
        return measurements.sorted { $0.date > $1.date }.first
    }
}
