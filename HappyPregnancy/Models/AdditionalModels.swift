import Foundation

// MARK: - Питание
struct MealEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let type: MealType
    let name: String
    let calories: Double
    let photoURL: URL?
    let notes: String
    
    enum MealType: String, Codable, CaseIterable {
        case breakfast = "Завтрак"
        case lunch = "Обед"
        case dinner = "Ужин"
        case snack = "Перекус"
    }
}

struct WaterIntake: Identifiable, Codable {
    let id: UUID
    let date: Date
    let amount: Double // в миллилитрах
}

struct Supplement: Identifiable, Codable {
    let id: UUID
    let name: String
    let dosage: String
    let frequency: String
    let startDate: Date
    let endDate: Date?
    let notes: String
}

// MARK: - Упражнения
struct Exercise: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let duration: TimeInterval
    let difficulty: Difficulty
    let trimester: Int
    let videoURL: URL?
    let imageURL: URL?
    
    enum Difficulty: String, Codable, CaseIterable {
        case easy = "Легкий"
        case medium = "Средний"
        case hard = "Сложный"
    }
}

struct ExerciseSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let exercise: Exercise
    let duration: TimeInterval
    let caloriesBurned: Double
    let notes: String
}

// MARK: - Сон
struct SleepEntry: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let quality: SleepQuality
    let position: SleepPosition
    let notes: String
    
    enum SleepQuality: String, Codable, CaseIterable {
        case excellent = "Отличный"
        case good = "Хороший"
        case fair = "Средний"
        case poor = "Плохой"
    }
    
    enum SleepPosition: String, Codable, CaseIterable {
        case left = "На левом боку"
        case right = "На правом боку"
        case back = "На спине"
        case stomach = "На животе"
    }
}

// MARK: - Подготовка к родам
struct Contraction: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let intensity: Int // 1-10
}

struct HospitalBagItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let category: BagCategory
    var isPacked: Bool
    
    enum BagCategory: String, Codable, CaseIterable {
        case documents = "Документы"
        case clothes = "Одежда"
        case hygiene = "Гигиена"
        case baby = "Для малыша"
        case other = "Прочее"
    }
}

// MARK: - Малыш
struct BabyInfo: Codable {
    var name: String?
    var gender: Gender?
    var birthDate: Date?
    var weight: Double?
    var height: Double?
    
    enum Gender: String, Codable, CaseIterable {
        case boy = "Мальчик"
        case girl = "Девочка"
        case unknown = "Неизвестно"
    }
}

struct BabyName: Identifiable, Codable {
    let id: UUID
    let name: String
    let gender: BabyInfo.Gender
    var isFavorite: Bool
    let meaning: String
    let origin: String
}

// MARK: - Социальные функции
struct ForumPost: Identifiable, Codable {
    let id: UUID
    let author: String
    let title: String
    let content: String
    let date: Date
    var likes: Int
    var comments: [ForumComment]
}

struct ForumComment: Identifiable, Codable {
    let id: UUID
    let author: String
    let content: String
    let date: Date
    var likes: Int
}

struct DoctorMessage: Identifiable, Codable {
    let id: UUID
    let sender: String
    let content: String
    let date: Date
    var isRead: Bool
    var attachments: [URL]?
}

// MARK: - Настройки
struct AppSettings: Codable {
    var isDarkMode: Bool
    var language: Language
    var notificationsEnabled: Bool
    var healthKitEnabled: Bool
    
    enum Language: String, Codable, CaseIterable {
        case russian = "Русский"
        case english = "English"
    }
}

// MARK: - Вспомогательные структуры
struct HealthData: Codable {
    var steps: Int
    var activeEnergy: Double
    var heartRate: Double
    var sleepHours: Double
    var date: Date
}

struct ExportData: Codable {
    var pregnancyInfo: PregnancyInfo
    var measurements: [WeightMeasurement]
    var medicalTests: [MedicalTest]
    var meals: [MealEntry]
    var exercises: [ExerciseSession]
    var sleepEntries: [SleepEntry]
    var contractions: [Contraction]
    var babyInfo: BabyInfo
} 