import Foundation
import CoreData

@objc(KicksSessionEntity)
public class KicksSessionEntity: NSManagedObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        date = Date()
    }

}
