import Foundation
import CoreData

class DoctorQuestionViewModel: ObservableObject {

    @Published var doctorQuestions: [DoctorQuestion] = []

    private let coreDataManager = CoreDataManager.shared

    init() {
        fetchDoctorQuestions()
    }

    func fetchDoctorQuestions() {
        let entities = coreDataManager.fetch(DoctorQuestionEntity.self)
        self.doctorQuestions = entities.map { DoctorQuestion(from: $0) }
    }

    func addDoctorQuestion(_ question: DoctorQuestion) {
        let newQuestion = DoctorQuestionEntity(context: coreDataManager.container.viewContext)
        newQuestion.id = question.id
        newQuestion.question = question.question
        newQuestion.isAnswered = question.isAnswered
        newQuestion.answer = question.answer
        newQuestion.date = question.date
        newQuestion.category = question.category.rawValue

        coreDataManager.saveContext()
        fetchDoctorQuestions()
    }

    func updateDoctorQuestion(_ question: DoctorQuestion) {
        let request = NSFetchRequest<DoctorQuestionEntity>(entityName: "DoctorQuestionEntity")
        request.predicate = NSPredicate(format: "id == %@", question.id as CVarArg)

        do {
            let results = try coreDataManager.container.viewContext.fetch(request)
            if let existingQuestion = results.first {
                existingQuestion.question = question.question
                existingQuestion.isAnswered = question.isAnswered
                existingQuestion.answer = question.answer
                existingQuestion.date = question.date
                existingQuestion.category = question.category.rawValue

                coreDataManager.saveContext()
                fetchDoctorQuestions()
            }
        } catch {
            print("Error updating doctor question: \(error)")
        }
    }

    func deleteDoctorQuestion(at offsets: IndexSet) {
        for index in offsets {
            let question = doctorQuestions[index]
            let request = NSFetchRequest<DoctorQuestionEntity>(entityName: "DoctorQuestionEntity")
            request.predicate = NSPredicate(format: "id == %@", question.id as CVarArg)

            do {
                let results = try coreDataManager.container.viewContext.fetch(request)
                if let existingQuestion = results.first {
                    coreDataManager.delete(existingQuestion)
                }
            } catch {
                print("Error deleting doctor question: \(error)")
            }
        }
        fetchDoctorQuestions()
    }
}
