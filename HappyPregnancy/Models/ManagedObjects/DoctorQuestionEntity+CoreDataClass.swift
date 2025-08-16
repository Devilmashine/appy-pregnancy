import Foundation
import CoreData

@objc(DoctorQuestionEntity)
public class DoctorQuestionEntity: NSManagedObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        date = Date()
        category = ""
        question = ""
    }

}
