import Foundation

// Модель для анализов
struct MedicalTest: Identifiable {
    let id: UUID
    var date: Date
    var type: TestType
    var results: [TestResult]
    var notes: String?
    var doctorName: String?
    var laboratory: String?
}

struct TestResult: Identifiable {
    let id: UUID
    var name: String
    var value: Double
    var unit: String
    var referenceRange: String
    var isNormal: Bool
}

enum TestType: String, CaseIterable {
    case blood = "Анализ крови"
    case urine = "Анализ мочи"
    case glucose = "Глюкозотолерантный тест"
    case ultrasound = "УЗИ"
    case other = "Другое"
}

// Модель для калькуляторов
struct BMICalculation {
    let weight: Double // кг
    let height: Double // см
    let date: Date
    
    var bmi: Double {
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    var category: String {
        switch bmi {
        case ..<18.5:
            return "Недостаточный вес"
        case 18.5..<25:
            return "Нормальный вес"
        case 25..<30:
            return "Избыточный вес"
        default:
            return "Ожирение"
        }
    }
}

struct WeightGainCalculation {
    let prePregnancyWeight: Double // кг
    let currentWeight: Double // кг
    let week: Int
    
    var totalGain: Double {
        return currentWeight - prePregnancyWeight
    }
    
    var isNormal: Bool {
        let recommendedGain: Double
        switch week {
        case 1...13: // Первый триместр
            recommendedGain = 1.5
        case 14...26: // Второй триместр
            recommendedGain = 5.0
        case 27...40: // Третий триместр
            recommendedGain = 9.0
        default:
            recommendedGain = 0
        }
        return abs(totalGain - recommendedGain) <= 2.0
    }
}

struct DueDateCalculation {
    let lastPeriodDate: Date
    let cycleLength: Int // дней
    
    var estimatedDueDate: Date {
        return Calendar.current.date(byAdding: .day, value: 280, to: lastPeriodDate) ?? Date()
    }
    
    var conceptionDate: Date {
        return Calendar.current.date(byAdding: .day, value: 14, to: lastPeriodDate) ?? Date()
    }
}

struct CalorieCalculation {
    let weight: Double // кг
    let height: Double // см
    let age: Int
    let activityLevel: ActivityLevel
    let trimester: Int
    
    var bmr: Double {
        // Формула Харриса-Бенедикта
        return 655.1 + (9.563 * weight) + (1.850 * height) - (4.676 * Double(age))
    }
    
    var tdee: Double {
        return bmr * activityLevel.multiplier
    }
    
    var recommendedCalories: Double {
        let baseCalories = tdee
        switch trimester {
        case 1:
            return baseCalories
        case 2:
            return baseCalories + 340
        case 3:
            return baseCalories + 450
        default:
            return baseCalories
        }
    }
}

enum ActivityLevel: String, CaseIterable {
    case sedentary = "Малоподвижный"
    case light = "Легкая активность"
    case moderate = "Умеренная активность"
    case active = "Высокая активность"
    case veryActive = "Очень высокая активность"
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }
} 