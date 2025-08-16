import Foundation
import CoreData

extension MealEntryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MealEntryEntity> {
        return NSFetchRequest<MealEntryEntity>(entityName: "MealEntryEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var type: String
    @NSManaged public var name: String
    @NSManaged public var calories: Double
    @NSManaged public var photoURL: URL?
    @NSManaged public var notes: String?

}

extension MealEntryEntity : Identifiable {

}
