import Foundation
import CoreData

extension KicksSessionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KicksSessionEntity> {
        return NSFetchRequest<KicksSessionEntity>(entityName: "KicksSessionEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var duration: Double
    @NSManaged public var kicksCount: Int32
    @NSManaged public var notes: String?

}

extension KicksSessionEntity : Identifiable {

}
