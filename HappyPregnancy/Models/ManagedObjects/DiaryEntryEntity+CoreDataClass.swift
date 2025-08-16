import Foundation
import CoreData

@objc(DiaryEntryEntity)
public class DiaryEntryEntity: NSManagedObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        date = Date()
    }

}
