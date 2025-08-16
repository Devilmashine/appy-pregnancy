import Foundation
import CoreData

extension DoctorQuestionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DoctorQuestionEntity> {
        return NSFetchRequest<DoctorQuestionEntity>(entityName: "DoctorQuestionEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var question: String
    @NSManaged public var isAnswered: Bool
    @NSManaged public var answer: String?
    @NSManaged public var date: Date
    @NSManaged public var category: String

}

extension DoctorQuestionEntity : Identifiable {

}
