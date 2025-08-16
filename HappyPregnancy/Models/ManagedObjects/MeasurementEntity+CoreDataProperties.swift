import Foundation
import CoreData

extension MeasurementEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MeasurementEntity> {
        return NSFetchRequest<MeasurementEntity>(entityName: "MeasurementEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var weight: Double
    @NSManaged public var bellyCircumference: Double
    @NSManaged public var notes: String?

}

extension MeasurementEntity : Identifiable {

}
