import SwiftUI

struct MedicalTestsView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @State private var showingAddTest = false
    @State private var selectedTestType: TestType = .blood
    
    var body: some View {
        NavigationView {
            List {
                // Фильтр по типу теста
                Picker("Тип теста", selection: $selectedTestType) {
                    ForEach(TestType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .listRowInsets(EdgeInsets())
                .padding()
                
                // Список тестов
                ForEach(filteredTests) { test in
                    NavigationLink(destination: TestDetailView(test: test)) {
                        TestRowView(test: test)
                    }
                }
            }
            .navigationTitle("Медицинские тесты")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTest = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTest) {
                AddTestView(viewModel: viewModel)
            }
        }
    }
    
    private var filteredTests: [MedicalTest] {
        viewModel.medicalTests.filter { $0.type == selectedTestType }
    }
}

struct TestRowView: View {
    let test: MedicalTest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(test.type.rawValue)
                    .font(.headline)
                Spacer()
                Text(test.date, formatter: dateFormatter)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let doctor = test.doctorName {
                Text("Врач: \(doctor)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let lab = test.laboratory {
                Text("Лаборатория: \(lab)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Показываем первые 2 результата
            if !test.results.isEmpty {
                ForEach(test.results.prefix(2)) { result in
                    HStack {
                        Text(result.name)
                        Spacer()
                        Text("\(result.value) \(result.unit)")
                            .foregroundColor(result.isNormal ? .green : .red)
                    }
                    .font(.subheadline)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct TestDetailView: View {
    let test: MedicalTest
    
    var body: some View {
        List {
            Section(header: Text("Общая информация")) {
                InfoRow(title: "Дата", value: test.date, formatter: dateFormatter)
                InfoRow(title: "Тип теста", value: test.type.rawValue)
                if let doctor = test.doctorName {
                    InfoRow(title: "Врач", value: doctor)
                }
                if let lab = test.laboratory {
                    InfoRow(title: "Лаборатория", value: lab)
                }
            }
            
            Section(header: Text("Результаты")) {
                ForEach(test.results) { result in
                    ResultRow(result: result)
                }
            }
            
            if !test.notes.isEmpty {
                Section(header: Text("Примечания")) {
                    Text(test.notes)
                        .font(.body)
                }
            }
        }
        .navigationTitle("Детали теста")
    }
}

struct AddTestView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var testType: TestType = .blood
    @State private var date = Date()
    @State private var doctorName = ""
    @State private var laboratory = ""
    @State private var notes = ""
    @State private var results: [TestResult] = []
    @State private var showingAddResult = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    Picker("Тип теста", selection: $testType) {
                        ForEach(TestType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    DatePicker("Дата", selection: $date, displayedComponents: [.date])
                    
                    TextField("Врач", text: $doctorName)
                    TextField("Лаборатория", text: $laboratory)
                }
                
                Section(header: Text("Результаты")) {
                    ForEach(results) { result in
                        ResultRow(result: result)
                    }
                    
                    Button("Добавить результат") {
                        showingAddResult = true
                    }
                }
                
                Section(header: Text("Примечания")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Новый тест")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveTest()
                    }
                    .disabled(results.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddResult) {
                AddResultView { result in
                    results.append(result)
                }
            }
        }
    }
    
    private func saveTest() {
        let test = MedicalTest(
            date: date,
            type: testType,
            results: results,
            notes: notes,
            doctorName: doctorName.isEmpty ? nil : doctorName,
            laboratory: laboratory.isEmpty ? nil : laboratory
        )
        
        viewModel.addMedicalTest(test)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddResultView: View {
    @Environment(\.presentationMode) var presentationMode
    let onSave: (TestResult) -> Void
    
    @State private var name = ""
    @State private var value = ""
    @State private var unit = ""
    @State private var referenceRange = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Параметры результата")) {
                    TextField("Название", text: $name)
                    TextField("Значение", text: $value)
                        .keyboardType(.decimalPad)
                    TextField("Единица измерения", text: $unit)
                    TextField("Референсный диапазон", text: $referenceRange)
                }
            }
            .navigationTitle("Новый результат")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveResult()
                    }
                    .disabled(name.isEmpty || value.isEmpty || unit.isEmpty)
                }
            }
        }
    }
    
    private func saveResult() {
        guard let value = Double(value) else { return }
        
        let result = TestResult(
            name: name,
            value: value,
            unit: unit,
            referenceRange: referenceRange.isEmpty ? nil : referenceRange
        )
        
        onSave(result)
        presentationMode.wrappedValue.dismiss()
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    init(title: String, value: Date, formatter: DateFormatter) {
        self.title = title
        self.value = formatter.string(from: value)
    }
    
    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}

struct ResultRow: View {
    let result: TestResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(result.name)
                    .font(.headline)
                Spacer()
                Text("\(String(format: "%.1f", result.value)) \(result.unit)")
                    .foregroundColor(result.isNormal ? .green : .red)
            }
            
            if let range = result.referenceRange {
                Text("Референсный диапазон: \(range)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}() 