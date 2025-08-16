import SwiftUI

struct CalculatorsView: View {
    @State private var selectedCalculator: CalculatorType = .bmi
    
    enum CalculatorType: String, CaseIterable {
        case bmi = "ИМТ"
        case weightGain = "Набор веса"
        case dueDate = "Дата родов"
        case calories = "Калории"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Выбор калькулятора
                Picker("Калькулятор", selection: $selectedCalculator) {
                    ForEach(CalculatorType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Контент калькулятора
                ScrollView {
                    switch selectedCalculator {
                    case .bmi:
                        BMICalculatorView()
                    case .weightGain:
                        WeightGainCalculatorView()
                    case .dueDate:
                        DueDateCalculatorView()
                    case .calories:
                        CalorieCalculatorView()
                    }
                }
            }
            .navigationTitle("Калькуляторы")
        }
    }
}

struct BMICalculatorView: View {
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var showingResult = false
    
    var body: some View {
        VStack(spacing: 20) {
            Form {
                Section(header: Text("Введите данные")) {
                    TextField("Вес (кг)", text: $weight)
                        .keyboardType(.decimalPad)
                    TextField("Рост (см)", text: $height)
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    Button("Рассчитать") {
                        showingResult = true
                    }
                    .disabled(weight.isEmpty || height.isEmpty)
                }
            }
            
            if showingResult, let bmi = calculateBMI() {
                ResultCard(title: "Результат") {
                    VStack(spacing: 10) {
                        Text("ИМТ: \(String(format: "%.1f", bmi.bmi))")
                            .font(.title2)
                            .bold()
                        
                        Text(bmi.category)
                            .foregroundColor(.secondary)
                        
                        Text("Рекомендации:")
                            .font(.headline)
                            .padding(.top)
                        
                        Text(getBMIRecommendations(bmi: bmi.bmi))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private func calculateBMI() -> BMICalculation? {
        guard let weight = Double(weight),
              let height = Double(height) else { return nil }
        
        return BMICalculation(weight: weight, height: height, date: Date())
    }
    
    private func getBMIRecommendations(bmi: Double) -> String {
        switch bmi {
        case ..<18.5:
            return "Рекомендуется увеличить калорийность рациона и проконсультироваться с врачом"
        case 18.5..<25:
            return "Ваш вес в норме. Продолжайте придерживаться здорового питания"
        case 25..<30:
            return "Рекомендуется следить за питанием и увеличить физическую активность"
        default:
            return "Рекомендуется проконсультироваться с врачом и диетологом"
        }
    }
}

struct WeightGainCalculatorView: View {
    @State private var prePregnancyWeight: String = ""
    @State private var currentWeight: String = ""
    @State private var week: String = ""
    @State private var showingResult = false
    
    var body: some View {
        VStack(spacing: 20) {
            Form {
                Section(header: Text("Введите данные")) {
                    TextField("Вес до беременности (кг)", text: $prePregnancyWeight)
                        .keyboardType(.decimalPad)
                    TextField("Текущий вес (кг)", text: $currentWeight)
                        .keyboardType(.decimalPad)
                    TextField("Неделя беременности", text: $week)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Button("Рассчитать") {
                        showingResult = true
                    }
                    .disabled(prePregnancyWeight.isEmpty || currentWeight.isEmpty || week.isEmpty)
                }
            }
            
            if showingResult, let calculation = calculateWeightGain() {
                ResultCard(title: "Результат") {
                    VStack(spacing: 10) {
                        Text("Набранный вес: \(String(format: "%.1f", calculation.totalGain)) кг")
                            .font(.title2)
                            .bold()
                        
                        Text(calculation.isNormal ? "В пределах нормы" : "Требуется консультация врача")
                            .foregroundColor(calculation.isNormal ? .green : .orange)
                        
                        Text("Рекомендации:")
                            .font(.headline)
                            .padding(.top)
                        
                        Text(getWeightGainRecommendations(calculation: calculation))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private func calculateWeightGain() -> WeightGainCalculation? {
        guard let preWeight = Double(prePregnancyWeight),
              let currentWeight = Double(currentWeight),
              let week = Int(week) else { return nil }
        
        return WeightGainCalculation(
            prePregnancyWeight: preWeight,
            currentWeight: currentWeight,
            week: week
        )
    }
    
    private func getWeightGainRecommendations(calculation: WeightGainCalculation) -> String {
        if calculation.isNormal {
            return "Продолжайте придерживаться здорового питания и регулярно посещайте врача"
        } else {
            return "Рекомендуется проконсультироваться с врачом для корректировки питания"
        }
    }
}

struct DueDateCalculatorView: View {
    @State private var lastPeriodDate = Date()
    @State private var cycleLength: String = "28"
    @State private var showingResult = false
    
    var body: some View {
        VStack(spacing: 20) {
            Form {
                Section(header: Text("Введите данные")) {
                    DatePicker(
                        "Первый день последней менструации",
                        selection: $lastPeriodDate,
                        displayedComponents: [.date]
                    )
                    
                    TextField("Длина цикла (дней)", text: $cycleLength)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Button("Рассчитать") {
                        showingResult = true
                    }
                }
            }
            
            if showingResult {
                let calculation = DueDateCalculation(
                    lastPeriodDate: lastPeriodDate,
                    cycleLength: Int(cycleLength) ?? 28
                )
                
                ResultCard(title: "Результат") {
                    VStack(spacing: 10) {
                        Text("Предполагаемая дата родов:")
                            .font(.headline)
                        
                        Text(calculation.estimatedDueDate, formatter: dateFormatter)
                            .font(.title2)
                            .bold()
                        
                        Text("Дата зачатия:")
                            .font(.headline)
                            .padding(.top)
                        
                        Text(calculation.conceptionDate, formatter: dateFormatter)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct CalorieCalculatorView: View {
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var age: String = ""
    @State private var activityLevel: ActivityLevel = .moderate
    @State private var trimester: Int = 1
    @State private var showingResult = false
    
    var body: some View {
        VStack(spacing: 20) {
            Form {
                Section(header: Text("Введите данные")) {
                    TextField("Вес (кг)", text: $weight)
                        .keyboardType(.decimalPad)
                    TextField("Рост (см)", text: $height)
                        .keyboardType(.decimalPad)
                    TextField("Возраст", text: $age)
                        .keyboardType(.numberPad)
                    
                    Picker("Уровень активности", selection: $activityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    
                    Picker("Триместр", selection: $trimester) {
                        Text("Первый").tag(1)
                        Text("Второй").tag(2)
                        Text("Третий").tag(3)
                    }
                }
                
                Section {
                    Button("Рассчитать") {
                        showingResult = true
                    }
                    .disabled(weight.isEmpty || height.isEmpty || age.isEmpty)
                }
            }
            
            if showingResult, let calculation = calculateCalories() {
                ResultCard(title: "Результат") {
                    VStack(spacing: 10) {
                        Text("Рекомендуемая калорийность:")
                            .font(.headline)
                        
                        Text("\(Int(calculation.recommendedCalories)) ккал")
                            .font(.title)
                            .bold()
                        
                        Text("Базовый обмен веществ:")
                            .font(.headline)
                            .padding(.top)
                        
                        Text("\(Int(calculation.bmr)) ккал")
                            .foregroundColor(.secondary)
                        
                        Text("Советы по питанию:")
                            .font(.headline)
                            .padding(.top)
                        
                        Text(getNutritionAdvice(calculation: calculation))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private func calculateCalories() -> CalorieCalculation? {
        guard let weight = Double(weight),
              let height = Double(height),
              let age = Int(age) else { return nil }
        
        return CalorieCalculation(
            weight: weight,
            height: height,
            age: age,
            activityLevel: activityLevel,
            trimester: trimester
        )
    }
    
    private func getNutritionAdvice(calculation: CalorieCalculation) -> String {
        "• Употребляйте достаточное количество белка\n• Включите в рацион продукты, богатые железом и кальцием\n• Пейте достаточно воды\n• Принимайте витамины для беременных"
    }
}

struct ResultCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text(title)
                .font(.headline)
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding()
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}() 