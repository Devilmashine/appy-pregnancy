import Foundation
import SwiftUI
import CoreData
import HealthKit

class PregnancyViewModel: ObservableObject {
    @Published var pregnancyInfo: PregnancyInfo
    @Published var diaryEntries: [DiaryEntry] = []
    @Published var kicksSessions: [KicksSession] = []
    @Published var checklistItems: [ChecklistItem] = []
    @Published var measurements: [Measurement]
    @Published var doctorQuestions: [DoctorQuestion] = []
    @Published var kicks: [Kick]
    @Published var medicalTests: [MedicalTest]
    
    // MARK: - Питание
    @Published var meals: [MealEntry]
    @Published var waterIntake: [WaterIntake]
    @Published var supplements: [Supplement]
    
    // MARK: - Упражнения
    @Published var exercises: [Exercise]
    @Published var exerciseSessions: [ExerciseSession]
    
    // MARK: - Сон
    @Published var sleepEntries: [SleepEntry]
    
    // MARK: - Подготовка к родам
    @Published var contractions: [Contraction]
    @Published var hospitalBagItems: [HospitalBagItem]
    
    // MARK: - Малыш
    @Published var babyInfo: BabyInfo
    @Published var babyNames: [BabyName]
    
    // MARK: - Социальные функции
    @Published var forumPosts: [ForumPost]
    @Published var doctorMessages: [DoctorMessage]
    
    // MARK: - Настройки
    @Published var settings: AppSettings
    
    // MARK: - HealthKit
    private let healthStore = HKHealthStore()
    
    init() {
        // Загрузка данных из UserDefaults или создание новых
        if let savedInfo = UserDefaults.standard.data(forKey: "pregnancyInfo"),
           let decodedInfo = try? JSONDecoder().decode(PregnancyInfo.self, from: savedInfo) {
            self.pregnancyInfo = decodedInfo
        } else {
            self.pregnancyInfo = PregnancyInfo()
        }
        
        if let savedMeasurements = UserDefaults.standard.data(forKey: "measurements"),
           let decodedMeasurements = try? JSONDecoder().decode([Measurement].self, from: savedMeasurements) {
            self.measurements = decodedMeasurements
        } else {
            self.measurements = []
        }
        
        if let savedKicks = UserDefaults.standard.data(forKey: "kicks"),
           let decodedKicks = try? JSONDecoder().decode([Kick].self, from: savedKicks) {
            self.kicks = decodedKicks
        } else {
            self.kicks = []
        }
        
        if let savedTests = UserDefaults.standard.data(forKey: "medicalTests"),
           let decodedTests = try? JSONDecoder().decode([MedicalTest].self, from: savedTests) {
            self.medicalTests = decodedTests
        } else {
            self.medicalTests = []
        }
        
        // Загрузка данных о питании
        self.meals = Self.loadData(forKey: "meals") ?? []
        self.waterIntake = Self.loadData(forKey: "waterIntake") ?? []
        self.supplements = Self.loadData(forKey: "supplements") ?? []
        
        // Загрузка данных об упражнениях
        self.exercises = Self.loadData(forKey: "exercises") ?? []
        self.exerciseSessions = Self.loadData(forKey: "exerciseSessions") ?? []
        
        // Загрузка данных о сне
        self.sleepEntries = Self.loadData(forKey: "sleepEntries") ?? []
        
        // Загрузка данных о подготовке к родам
        self.contractions = Self.loadData(forKey: "contractions") ?? []
        self.hospitalBagItems = Self.loadData(forKey: "hospitalBagItems") ?? []
        
        // Загрузка данных о малыше
        self.babyInfo = Self.loadData(forKey: "babyInfo") ?? BabyInfo()
        self.babyNames = Self.loadData(forKey: "babyNames") ?? []
        
        // Загрузка социальных данных
        self.forumPosts = Self.loadData(forKey: "forumPosts") ?? []
        self.doctorMessages = Self.loadData(forKey: "doctorMessages") ?? []
        
        // Загрузка настроек
        self.settings = Self.loadData(forKey: "settings") ?? AppSettings(
            isDarkMode: false,
            language: .russian,
            notificationsEnabled: true,
            healthKitEnabled: false
        )
        
        // Инициализация HealthKit
        if settings.healthKitEnabled {
            setupHealthKit()
        }
    }
    
    // MARK: - Вспомогательные методы загрузки данных
    private static func loadData<T: Codable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - Методы сохранения данных
    private func saveData<T: Codable>(_ data: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    // MARK: - Pregnancy Info Methods
    func calculateCurrentWeek() -> Int {
        guard let startDate = pregnancyInfo.startDate else { return 0 }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekOfYear], from: startDate, to: Date())
        return components.weekOfYear ?? 0
    }
    
    func calculateDueDate(from startDate: Date) -> Date {
        return Calendar.current.date(byAdding: .day, value: 280, to: startDate) ?? Date()
    }
    
    // MARK: - Diary Methods
    func addDiaryEntry(_ entry: DiaryEntry) {
        diaryEntries.append(entry)
        saveData()
    }
    
    func updateDiaryEntry(_ entry: DiaryEntry) {
        if let index = diaryEntries.firstIndex(where: { $0.id == entry.id }) {
            diaryEntries[index] = entry
            saveData()
        }
    }
    
    // MARK: - Kicks Counter Methods
    func addKicksSession(_ session: KicksSession) {
        kicksSessions.append(session)
        saveData()
    }
    
    func getKicksForToday() -> [KicksSession] {
        let calendar = Calendar.current
        return kicksSessions.filter { calendar.isDateInToday($0.date) }
    }
    
    // MARK: - Checklist Methods
    func addChecklistItem(_ item: ChecklistItem) {
        checklistItems.append(item)
        saveData()
    }
    
    func toggleChecklistItem(_ item: ChecklistItem) {
        if let index = checklistItems.firstIndex(where: { $0.id == item.id }) {
            var updatedItem = item
            updatedItem.isCompleted.toggle()
            checklistItems[index] = updatedItem
            saveData()
        }
    }
    
    // MARK: - Measurement Methods
    func addMeasurement(_ measurement: Measurement) {
        measurements.append(measurement)
        saveData()
    }
    
    func deleteMeasurement(at indexSet: IndexSet) {
        measurements.remove(atOffsets: indexSet)
        saveData()
    }
    
    func getLatestMeasurement() -> Measurement? {
        return measurements.sorted { $0.date > $1.date }.first
    }
    
    // MARK: - Doctor Questions Methods
    func addDoctorQuestion(_ question: DoctorQuestion) {
        doctorQuestions.append(question)
        saveData()
    }
    
    func updateDoctorQuestion(_ question: DoctorQuestion) {
        if let index = doctorQuestions.firstIndex(where: { $0.id == question.id }) {
            doctorQuestions[index] = question
            saveData()
        }
    }
    
    // MARK: - Kicks
    func addKick(_ kick: Kick) {
        kicks.append(kick)
        saveData()
    }
    
    func deleteKick(at indexSet: IndexSet) {
        kicks.remove(atOffsets: indexSet)
        saveData()
    }
    
    // MARK: - Medical Tests
    func addMedicalTest(_ test: MedicalTest) {
        medicalTests.append(test)
        saveData()
    }
    
    func deleteMedicalTest(at indexSet: IndexSet) {
        medicalTests.remove(atOffsets: indexSet)
        saveData()
    }
    
    // MARK: - Data Persistence
    private func saveData() {
        if let encodedInfo = try? JSONEncoder().encode(pregnancyInfo) {
            UserDefaults.standard.set(encodedInfo, forKey: "pregnancyInfo")
        }
        
        if let encodedMeasurements = try? JSONEncoder().encode(measurements) {
            UserDefaults.standard.set(encodedMeasurements, forKey: "measurements")
        }
        
        if let encodedKicks = try? JSONEncoder().encode(kicks) {
            UserDefaults.standard.set(encodedKicks, forKey: "kicks")
        }
        
        if let encodedTests = try? JSONEncoder().encode(medicalTests) {
            UserDefaults.standard.set(encodedTests, forKey: "medicalTests")
        }
        
        if let encodedMeals = try? JSONEncoder().encode(meals) {
            UserDefaults.standard.set(encodedMeals, forKey: "meals")
        }
        
        if let encodedWaterIntake = try? JSONEncoder().encode(waterIntake) {
            UserDefaults.standard.set(encodedWaterIntake, forKey: "waterIntake")
        }
        
        if let encodedSupplements = try? JSONEncoder().encode(supplements) {
            UserDefaults.standard.set(encodedSupplements, forKey: "supplements")
        }
        
        if let encodedExercises = try? JSONEncoder().encode(exercises) {
            UserDefaults.standard.set(encodedExercises, forKey: "exercises")
        }
        
        if let encodedExerciseSessions = try? JSONEncoder().encode(exerciseSessions) {
            UserDefaults.standard.set(encodedExerciseSessions, forKey: "exerciseSessions")
        }
        
        if let encodedSleepEntries = try? JSONEncoder().encode(sleepEntries) {
            UserDefaults.standard.set(encodedSleepEntries, forKey: "sleepEntries")
        }
        
        if let encodedContractions = try? JSONEncoder().encode(contractions) {
            UserDefaults.standard.set(encodedContractions, forKey: "contractions")
        }
        
        if let encodedHospitalBagItems = try? JSONEncoder().encode(hospitalBagItems) {
            UserDefaults.standard.set(encodedHospitalBagItems, forKey: "hospitalBagItems")
        }
        
        if let encodedBabyInfo = try? JSONEncoder().encode(babyInfo) {
            UserDefaults.standard.set(encodedBabyInfo, forKey: "babyInfo")
        }
        
        if let encodedBabyNames = try? JSONEncoder().encode(babyNames) {
            UserDefaults.standard.set(encodedBabyNames, forKey: "babyNames")
        }
        
        if let encodedForumPosts = try? JSONEncoder().encode(forumPosts) {
            UserDefaults.standard.set(encodedForumPosts, forKey: "forumPosts")
        }
        
        if let encodedDoctorMessages = try? JSONEncoder().encode(doctorMessages) {
            UserDefaults.standard.set(encodedDoctorMessages, forKey: "doctorMessages")
        }
        
        if let encodedSettings = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encodedSettings, forKey: "settings")
        }
    }
    
    private func loadData() {
        // TODO: Implement data loading from CoreData
    }
    
    // MARK: - Питание
    func addMeal(_ meal: MealEntry) {
        meals.append(meal)
        saveData(meals, forKey: "meals")
    }
    
    func addWaterIntake(_ intake: WaterIntake) {
        waterIntake.append(intake)
        saveData(waterIntake, forKey: "waterIntake")
    }
    
    func addSupplement(_ supplement: Supplement) {
        supplements.append(supplement)
        saveData(supplements, forKey: "supplements")
    }
    
    // MARK: - Упражнения
    func addExercise(_ exercise: Exercise) {
        exercises.append(exercise)
        saveData(exercises, forKey: "exercises")
    }
    
    func addExerciseSession(_ session: ExerciseSession) {
        exerciseSessions.append(session)
        saveData(exerciseSessions, forKey: "exerciseSessions")
    }
    
    // MARK: - Сон
    func addSleepEntry(_ entry: SleepEntry) {
        sleepEntries.append(entry)
        saveData(sleepEntries, forKey: "sleepEntries")
    }
    
    // MARK: - Подготовка к родам
    func addContraction(_ contraction: Contraction) {
        contractions.append(contraction)
        saveData(contractions, forKey: "contractions")
    }
    
    func updateHospitalBagItem(_ item: HospitalBagItem) {
        if let index = hospitalBagItems.firstIndex(where: { $0.id == item.id }) {
            hospitalBagItems[index] = item
            saveData(hospitalBagItems, forKey: "hospitalBagItems")
        }
    }
    
    // MARK: - Малыш
    func updateBabyInfo(_ info: BabyInfo) {
        babyInfo = info
        saveData(babyInfo, forKey: "babyInfo")
    }
    
    func addBabyName(_ name: BabyName) {
        babyNames.append(name)
        saveData(babyNames, forKey: "babyNames")
    }
    
    // MARK: - Социальные функции
    func addForumPost(_ post: ForumPost) {
        forumPosts.append(post)
        saveData(forumPosts, forKey: "forumPosts")
    }
    
    func addDoctorMessage(_ message: DoctorMessage) {
        doctorMessages.append(message)
        saveData(doctorMessages, forKey: "doctorMessages")
    }
    
    // MARK: - Настройки
    func updateSettings(_ newSettings: AppSettings) {
        settings = newSettings
        saveData(settings, forKey: "settings")
        
        if settings.healthKitEnabled {
            setupHealthKit()
        }
    }
    
    // MARK: - HealthKit
    private func setupHealthKit() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if !success {
                print("HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // MARK: - Экспорт данных
    func exportData() -> ExportData {
        ExportData(
            pregnancyInfo: pregnancyInfo,
            measurements: measurements,
            medicalTests: medicalTests,
            meals: meals,
            exercises: exerciseSessions,
            sleepEntries: sleepEntries,
            contractions: contractions,
            babyInfo: babyInfo
        )
    }
} 