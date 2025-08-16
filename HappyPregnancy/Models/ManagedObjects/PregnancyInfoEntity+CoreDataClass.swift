import Foundation
import CoreData

@objc(PregnancyInfoEntity)
public class PregnancyInfoEntity: NSManagedObject {

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
    }

}
