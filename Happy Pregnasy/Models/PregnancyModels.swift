import Foundation
import CoreData

// Модель для хранения информации о беременности
struct PregnancyInfo: Identifiable {
    let id: UUID
    var startDate: Date
    var dueDate: Date
    var currentWeek: Int
    var weight: Double
    var height: Double
    var bloodType: String
    var doctorName: String
    var hospitalName: String
}

// Модель для дневника
struct DiaryEntry: Identifiable {
    let id: UUID
    var date: Date
    var mood: Int // 1-5
    var symptoms: [String]
    var notes: String
    var photos: [Data]?
}

// Модель для подсчета шевелений
struct KicksSession: Identifiable {
    let id: UUID
    var date: Date
    var duration: TimeInterval
    var kicksCount: Int
    var notes: String?
}

// Модель для чек-листа
struct ChecklistItem: Identifiable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var category: ChecklistCategory
    var dueDate: Date?
    var notes: String?
}

enum ChecklistCategory: String, CaseIterable {
    case firstTrimester = "Первый триместр"
    case secondTrimester = "Второй триместр"
    case thirdTrimester = "Третий триместр"
    case hospitalBag = "Сумка в роддом"
    case babyItems = "Вещи для малыша"
    case homePreparation = "Подготовка дома"
}

// Модель для измерений
struct Measurement: Identifiable {
    let id: UUID
    var date: Date
    var weight: Double
    var bellyCircumference: Double
    var notes: String?
}

// Модель для вопросов к врачу
struct DoctorQuestion: Identifiable {
    let id: UUID
    var question: String
    var isAnswered: Bool
    var answer: String?
    var date: Date
    var category: QuestionCategory
}

enum QuestionCategory: String, CaseIterable {
    case general = "Общие вопросы"
    case nutrition = "Питание"
    case symptoms = "Симптомы"
    case tests = "Анализы"
    case preparation = "Подготовка к родам"
} 