import Foundation
import CoreData

@objc(ChecklistItemEntity)
public class ChecklistItemEntity: NSManagedObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        title = ""
        category = ""
    }

}
