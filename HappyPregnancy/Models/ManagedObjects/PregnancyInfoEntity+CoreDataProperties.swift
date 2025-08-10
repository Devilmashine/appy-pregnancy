import Foundation
import CoreData

extension PregnancyInfoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PregnancyInfoEntity> {
        return NSFetchRequest<PregnancyInfoEntity>(entityName: "PregnancyInfoEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var startDate: Date?
    @NSManaged public var dueDate: Date?
    @NSManaged public var currentWeek: Int32
    @NSManaged public var weight: Double
    @NSManaged public var height: Double
    @NSManaged public var bloodType: String?
    @NSManaged public var doctorName: String?
    @NSManaged public var hospitalName: String?

}

extension PregnancyInfoEntity : Identifiable {

}
