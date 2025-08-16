import Foundation
import CoreData

@objc(MealEntryEntity)
public class MealEntryEntity: NSManagedObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        date = Date()
        name = ""
        type = ""
    }

}
