import SwiftUI
import Charts

struct BabyView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @State private var selectedTab = 0
    @State private var showingAddName = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Сегментированный контрол для переключения между вкладками
                Picker("", selection: $selectedTab) {
                    Text("Развитие").tag(0)
                    Text("Имена").tag(1)
                    Text("Размеры").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Контент в зависимости от выбранной вкладки
                TabView(selection: $selectedTab) {
                    // Вкладка развития
                    BabyDevelopmentView(viewModel: viewModel)
                        .tag(0)
                    
                    // Вкладка имен
                    BabyNamesView(viewModel: viewModel)
                        .tag(1)
                    
                    // Вкладка размеров
                    BabySizesView(viewModel: viewModel)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Малыш")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedTab == 1 {
                        Button(action: {
                            showingAddName = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddName) {
                AddBabyNameView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Развитие малыша
struct BabyDevelopmentView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Текущая неделя
                WeekCard(week: viewModel.pregnancyInfo.currentWeek)
                
                // Размер малыша
                SizeComparisonCard(size: getSizeForWeek(viewModel.pregnancyInfo.currentWeek))
                
                // Развитие
                DevelopmentCard(week: viewModel.pregnancyInfo.currentWeek)
            }
            .padding()
        }
    }
    
    private func getSizeForWeek(_ week: Int) -> String {
        // Здесь можно добавить логику определения размера плода по неделям
        let sizes = [
            "маковое зернышко", "чечевица", "горошина", "виноградина",
            "клубника", "лимон", "авокадо", "манго", "баклажан",
            "дыня", "тыква", "арбуз"
        ]
        return sizes[min(week / 4, sizes.count - 1)]
    }
}

struct WeekCard: View {
    let week: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Text("\(week) неделя")
                .font(.title)
                .bold()
            
            Text("\(Int(Double(week) * 7.0)) дней")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ProgressView(value: Double(week), total: 40)
                .tint(.pink)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct SizeComparisonCard: View {
    let size: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Размер малыша")
                .font(.headline)
            
            Text(size)
                .font(.title2)
                .bold()
            
            // TODO: Добавить изображение для сравнения
            Image(systemName: "circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.pink)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct DevelopmentCard: View {
    let week: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Развитие на этой неделе")
                .font(.headline)
            
            ForEach(getDevelopmentForWeek(week), id: \.self) { development in
                HStack(alignment: .top) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(development)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func getDevelopmentForWeek(_ week: Int) -> [String] {
        // Здесь можно добавить более подробную информацию о развитии по неделям
        return [
            "Формирование основных органов",
            "Развитие нервной системы",
            "Начало движения"
        ]
    }
}

// MARK: - Имена для малыша
struct BabyNamesView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @State private var searchText = ""
    @State private var selectedGender: BabyName.Gender?
    
    var body: some View {
        VStack {
            // Поиск и фильтры
            HStack {
                TextField("Поиск", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Picker("Пол", selection: $selectedGender) {
                    Text("Все").tag(nil as BabyName.Gender?)
                    Text("Мальчик").tag(BabyName.Gender.male as BabyName.Gender?)
                    Text("Девочка").tag(BabyName.Gender.female as BabyName.Gender?)
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding()
            
            // Список имен
            List {
                ForEach(filteredNames) { name in
                    BabyNameRowView(name: name)
                }
            }
        }
    }
    
    private var filteredNames: [BabyName] {
        viewModel.babyNames.filter { name in
            (selectedGender == nil || name.gender == selectedGender) &&
            (searchText.isEmpty || name.name.localizedCaseInsensitiveContains(searchText))
        }
    }
}

struct BabyNameRowView: View {
    let name: BabyName
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name.name)
                    .font(.headline)
                
                Text(name.meaning)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if name.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Размеры малыша
struct BabySizesView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // График роста
                VStack(alignment: .leading) {
                    Text("Рост малыша")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart {
                        ForEach(getGrowthData()) { data in
                            LineMark(
                                x: .value("Неделя", data.week),
                                y: .value("Рост", data.height)
                            )
                            .foregroundStyle(Color.pink.gradient)
                        }
                    }
                    .frame(height: 200)
                    .padding()
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                
                // Таблица размеров
                VStack(alignment: .leading, spacing: 12) {
                    Text("Размеры по неделям")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(getSizeData()) { size in
                        SizeRowView(size: size)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
            }
            .padding()
        }
    }
    
    private func getGrowthData() -> [GrowthData] {
        // Здесь можно добавить реальные данные о росте
        return (1...40).map { week in
            GrowthData(week: week, height: Double(week) * 0.5)
        }
    }
    
    private func getSizeData() -> [SizeData] {
        // Здесь можно добавить реальные данные о размерах
        return [
            SizeData(week: 12, height: 6.0, weight: 14.0),
            SizeData(week: 20, height: 25.0, weight: 300.0),
            SizeData(week: 28, height: 35.0, weight: 1000.0),
            SizeData(week: 36, height: 45.0, weight: 2600.0)
        ]
    }
}

struct GrowthData: Identifiable {
    let id = UUID()
    let week: Int
    let height: Double
}

struct SizeData: Identifiable {
    let id = UUID()
    let week: Int
    let height: Double
    let weight: Double
}

struct SizeRowView: View {
    let size: SizeData
    
    var body: some View {
        HStack {
            Text("\(size.week) неделя")
                .font(.subheadline)
                .bold()
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Рост: \(String(format: "%.1f", size.height)) см")
                    .font(.caption)
                Text("Вес: \(String(format: "%.0f", size.weight)) г")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Добавление имени
struct AddBabyNameView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var meaning = ""
    @State private var gender: BabyName.Gender = .male
    @State private var isFavorite = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Имя")) {
                    TextField("Имя", text: $name)
                }
                
                Section(header: Text("Значение")) {
                    TextEditor(text: $meaning)
                        .frame(height: 100)
                }
                
                Section(header: Text("Пол")) {
                    Picker("Пол", selection: $gender) {
                        Text("Мальчик").tag(BabyName.Gender.male)
                        Text("Девочка").tag(BabyName.Gender.female)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Toggle("В избранном", isOn: $isFavorite)
                }
            }
            .navigationTitle("Новое имя")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveName()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveName() {
        let babyName = BabyName(
            id: UUID(),
            name: name,
            meaning: meaning,
            gender: gender,
            isFavorite: isFavorite
        )
        
        viewModel.addBabyName(babyName)
        presentationMode.wrappedValue.dismiss()
    }
} 