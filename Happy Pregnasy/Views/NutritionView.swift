import SwiftUI
import PhotosUI

struct NutritionView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @State private var selectedTab = 0
    @State private var showingAddMeal = false
    @State private var showingAddWater = false
    @State private var showingAddSupplement = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Сегментированный контрол для переключения между вкладками
                Picker("", selection: $selectedTab) {
                    Text("Питание").tag(0)
                    Text("Вода").tag(1)
                    Text("Витамины").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Контент в зависимости от выбранной вкладки
                TabView(selection: $selectedTab) {
                    // Вкладка питания
                    MealsListView(viewModel: viewModel)
                        .tag(0)
                    
                    // Вкладка воды
                    WaterIntakeView(viewModel: viewModel)
                        .tag(1)
                    
                    // Вкладка витаминов
                    SupplementsView(viewModel: viewModel)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Питание")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        switch selectedTab {
                        case 0: showingAddMeal = true
                        case 1: showingAddWater = true
                        case 2: showingAddSupplement = true
                        default: break
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMeal) {
                AddMealView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingAddWater) {
                AddWaterIntakeView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingAddSupplement) {
                AddSupplementView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Список приемов пищи
struct MealsListView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack {
            // Выбор даты
            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
            
            // Список приемов пищи
            List {
                ForEach(MealEntry.MealType.allCases, id: \.self) { type in
                    Section(header: Text(type.rawValue)) {
                        ForEach(filteredMeals(for: type)) { meal in
                            MealRowView(meal: meal)
                        }
                    }
                }
            }
        }
    }
    
    private func filteredMeals(for type: MealEntry.MealType) -> [MealEntry] {
        viewModel.meals.filter { meal in
            Calendar.current.isDate(meal.date, inSameDayAs: selectedDate) &&
            meal.type == type
        }
    }
}

struct MealRowView: View {
    let meal: MealEntry
    
    var body: some View {
        HStack {
            if let photoURL = meal.photoURL {
                AsyncImage(url: photoURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading) {
                Text(meal.name)
                    .font(.headline)
                Text("\(Int(meal.calories)) ккал")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(meal.date, formatter: timeFormatter)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Водный баланс
struct WaterIntakeView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack {
            // График потребления воды
            WaterIntakeChart(waterIntake: filteredWaterIntake)
                .frame(height: 200)
                .padding()
            
            // Список записей
            List {
                ForEach(filteredWaterIntake) { intake in
                    HStack {
                        Text("\(Int(intake.amount)) мл")
                            .font(.headline)
                        Spacer()
                        Text(intake.date, formatter: timeFormatter)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var filteredWaterIntake: [WaterIntake] {
        viewModel.waterIntake.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
}

struct WaterIntakeChart: View {
    let waterIntake: [WaterIntake]
    
    var body: some View {
        // TODO: Реализовать график потребления воды
        Text("График потребления воды")
    }
}

// MARK: - Витамины и добавки
struct SupplementsView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.supplements) { supplement in
                VStack(alignment: .leading, spacing: 8) {
                    Text(supplement.name)
                        .font(.headline)
                    
                    Text("Дозировка: \(supplement.dosage)")
                        .font(.subheadline)
                    
                    Text("Частота: \(supplement.frequency)")
                        .font(.subheadline)
                    
                    if !supplement.notes.isEmpty {
                        Text(supplement.notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - Добавление приема пищи
struct AddMealView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var type: MealEntry.MealType = .breakfast
    @State private var calories = ""
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoURL: URL?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Название блюда", text: $name)
                    
                    Picker("Тип приема пищи", selection: $type) {
                        ForEach(MealEntry.MealType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("Калории", text: $calories)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Фото")) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        if let photoURL = photoURL {
                            AsyncImage(url: photoURL) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(height: 200)
                        } else {
                            Text("Выбрать фото")
                        }
                    }
                }
                
                Section(header: Text("Примечания")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Новый прием пищи")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveMeal()
                    }
                    .disabled(name.isEmpty || calories.isEmpty)
                }
            }
        }
    }
    
    private func saveMeal() {
        guard let caloriesValue = Double(calories) else { return }
        
        let meal = MealEntry(
            id: UUID(),
            date: Date(),
            type: type,
            name: name,
            calories: caloriesValue,
            photoURL: photoURL,
            notes: notes
        )
        
        viewModel.addMeal(meal)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Добавление записи о воде
struct AddWaterIntakeView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var amount = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Количество воды")) {
                    TextField("Объем (мл)", text: $amount)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Добавить воду")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveWaterIntake()
                    }
                    .disabled(amount.isEmpty)
                }
            }
        }
    }
    
    private func saveWaterIntake() {
        guard let amountValue = Double(amount) else { return }
        
        let intake = WaterIntake(
            id: UUID(),
            date: Date(),
            amount: amountValue
        )
        
        viewModel.addWaterIntake(intake)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Добавление витамина/добавки
struct AddSupplementView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var dosage = ""
    @State private var frequency = ""
    @State private var notes = ""
    @State private var endDate: Date?
    @State private var hasEndDate = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Название", text: $name)
                    TextField("Дозировка", text: $dosage)
                    TextField("Частота приема", text: $frequency)
                }
                
                Section(header: Text("Период приема")) {
                    Toggle("Есть дата окончания", isOn: $hasEndDate)
                    
                    if hasEndDate {
                        DatePicker("Дата окончания", selection: Binding(
                            get: { endDate ?? Date() },
                            set: { endDate = $0 }
                        ), displayedComponents: [.date])
                    }
                }
                
                Section(header: Text("Примечания")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Новая добавка")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveSupplement()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty || frequency.isEmpty)
                }
            }
        }
    }
    
    private func saveSupplement() {
        let supplement = Supplement(
            id: UUID(),
            name: name,
            dosage: dosage,
            frequency: frequency,
            startDate: Date(),
            endDate: hasEndDate ? endDate : nil,
            notes: notes
        )
        
        viewModel.addSupplement(supplement)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Вспомогательные компоненты
private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}() 