import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = PregnancyViewModel()
    @State private var showingAddPregnancyInfo = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let info = viewModel.pregnancyInfo {
                        PregnancyProgressView(info: info)
                    } else {
                        EmptyPregnancyView(showingAddPregnancyInfo: $showingAddPregnancyInfo)
                    }
                    
                    if viewModel.pregnancyInfo != nil {
                        WeekInfoView(week: viewModel.calculateCurrentWeek())
                        ImportantDatesView()
                        TipsView()
                    }
                }
                .padding()
            }
            .navigationTitle("Календарь")
            .sheet(isPresented: $showingAddPregnancyInfo) {
                AddPregnancyInfoView(viewModel: viewModel)
            }
        }
    }
}

struct PregnancyProgressView: View {
    let info: PregnancyInfo
    
    var body: some View {
        VStack(spacing: 15) {
            Text("\(info.currentWeek) неделя")
                .font(.title)
                .bold()
            
            ProgressView(value: Double(info.currentWeek), total: 40)
                .progressViewStyle(LinearProgressViewStyle(tint: .pink))
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Начало: \(info.startDate, formatter: dateFormatter)")
                    Text("ПДР: \(info.dueDate, formatter: dateFormatter)")
                }
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct EmptyPregnancyView: View {
    @Binding var showingAddPregnancyInfo: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.pink)
            
            Text("Добавьте информацию о беременности")
                .font(.headline)
            
            Button(action: { showingAddPregnancyInfo = true }) {
                Text("Добавить")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct WeekInfoView: View {
    let week: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Информация о \(week) неделе")
                .font(.headline)
            
            Text("Здесь будет информация о развитии малыша и изменениях в организме мамы")
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ImportantDatesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Важные даты")
                .font(.headline)
            
            ForEach(1...3, id: \.self) { _ in
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.pink)
                    Text("Дата события")
                    Spacer()
                    Text("00.00.0000")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct TipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Советы на эту неделю")
                .font(.headline)
            
            Text("Здесь будут полезные советы и рекомендации")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct AddPregnancyInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: PregnancyViewModel
    
    @State private var startDate = Date()
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var bloodType: String = ""
    @State private var doctorName: String = ""
    @State private var hospitalName: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    DatePicker("Дата начала", selection: $startDate, displayedComponents: .date)
                    TextField("Вес (кг)", text: $weight)
                        .keyboardType(.decimalPad)
                    TextField("Рост (см)", text: $height)
                        .keyboardType(.decimalPad)
                    TextField("Группа крови", text: $bloodType)
                }
                
                Section(header: Text("Медицинская информация")) {
                    TextField("ФИО врача", text: $doctorName)
                    TextField("Название клиники", text: $hospitalName)
                }
                
                Section {
                    Button("Сохранить") {
                        savePregnancyInfo()
                    }
                }
            }
            .navigationTitle("Новая беременность")
            .navigationBarItems(trailing: Button("Отмена") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func savePregnancyInfo() {
        let info = PregnancyInfo(
            id: UUID(),
            startDate: startDate,
            dueDate: viewModel.calculateDueDate(from: startDate),
            currentWeek: 1,
            weight: Double(weight) ?? 0,
            height: Double(height) ?? 0,
            bloodType: bloodType,
            doctorName: doctorName,
            hospitalName: hospitalName
        )
        
        viewModel.pregnancyInfo = info
        presentationMode.wrappedValue.dismiss()
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}() 