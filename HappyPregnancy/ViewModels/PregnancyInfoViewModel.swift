import Foundation
import SwiftUI
import CoreData
import HealthKit

class PregnancyInfoViewModel: ObservableObject {

    @Published var pregnancyInfo: PregnancyInfo?

    private let coreDataManager = CoreDataManager.shared

    init() {
        fetchPregnancyInfo()
    }

    func fetchPregnancyInfo() {
        let entities = coreDataManager.fetch(PregnancyInfoEntity.self)
        if let entity = entities.first {
            self.pregnancyInfo = PregnancyInfo(from: entity)
        }
    }






    // MARK: - Data Manipulation


    // ... (other methods will be refactored later)
}

// MARK: - Model Extensions for Core Data

extension PregnancyInfo {
    init(from entity: PregnancyInfoEntity) {
        self.id = entity.id
        self.startDate = entity.startDate ?? Date()
        self.dueDate = entity.dueDate ?? Date()
        self.currentWeek = Int(entity.currentWeek)
        self.weight = entity.weight
        self.height = entity.height
        self.bloodType = entity.bloodType ?? ""
        self.doctorName = entity.doctorName ?? ""
        self.hospitalName = entity.hospitalName ?? ""
    }
}

extension DiaryEntry {
    init(from entity: DiaryEntryEntity) {
        self.id = entity.id
        self.date = entity.date
        self.mood = Int(entity.mood)
        self.symptoms = entity.symptoms ?? []
        self.notes = entity.notes ?? ""
        self.photos = entity.photos
    }
}

extension KicksSession {
    init(from entity: KicksSessionEntity) {
        self.id = entity.id
        self.date = entity.date
        self.duration = entity.duration
        self.kicksCount = Int(entity.kicksCount)
        self.notes = entity.notes
    }
}

extension ChecklistItem {
    init(from entity: ChecklistItemEntity) {
        self.id = entity.id
        self.title = entity.title
        self.isCompleted = entity.isCompleted
        self.category = ChecklistCategory(rawValue: entity.category) ?? .firstTrimester
        self.dueDate = entity.dueDate
        self.notes = entity.notes
    }
}

extension WeightMeasurement {
    init(from entity: MeasurementEntity) {
        self.id = entity.id ?? UUID()
        self.date = entity.date ?? Date()
        self.weight = entity.weight
        self.bellyCircumference = entity.bellyCircumference
        self.notes = entity.notes
    }
}

extension DoctorQuestion {
    init(from entity: DoctorQuestionEntity) {
        self.id = entity.id
        self.question = entity.question
        self.isAnswered = entity.isAnswered
        self.answer = entity.answer
        self.date = entity.date
        self.category = QuestionCategory(rawValue: entity.category) ?? .general
    }
}
