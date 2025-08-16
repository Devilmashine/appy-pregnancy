import Foundation
import CoreData

extension DiaryEntryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiaryEntryEntity> {
        return NSFetchRequest<DiaryEntryEntity>(entityName: "DiaryEntryEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var mood: Int16
    @NSManaged public var symptoms: [String]?
    @NSManaged public var notes: String?
    @NSManaged public var photos: [Data]?

}

extension DiaryEntryEntity : Identifiable {

}
