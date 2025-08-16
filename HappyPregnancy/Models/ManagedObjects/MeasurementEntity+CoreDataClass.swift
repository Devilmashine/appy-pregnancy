import Foundation
import CoreData

@objc(MeasurementEntity)
public class MeasurementEntity: NSManagedObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        date = Date()
    }

}
