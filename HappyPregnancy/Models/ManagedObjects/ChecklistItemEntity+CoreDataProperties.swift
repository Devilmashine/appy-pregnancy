import Foundation
import CoreData

extension ChecklistItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChecklistItemEntity> {
        return NSFetchRequest<ChecklistItemEntity>(entityName: "ChecklistItemEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var isCompleted: Bool
    @NSManaged public var category: String
    @NSManaged public var dueDate: Date?
    @NSManaged public var notes: String?

}

extension ChecklistItemEntity : Identifiable {

}
