import SwiftUI
import Charts

struct ProfileView: View {
    @StateObject private var viewModel = PregnancyViewModel()
    @State private var showingEditProfile = false
    @State private var showingAddMeasurement = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Профиль
                    ProfileHeaderView(info: viewModel.pregnancyInfo)
                    
                    // Графики
                    if !viewModel.measurements.isEmpty {
                        MeasurementsChartView(measurements: viewModel.measurements)
                    }
                    
                    // Вкладки
                    Picker("", selection: $selectedTab) {
                        Text("Измерения").tag(0)
                        Text("Вопросы к врачу").tag(1)
                        Text("Настройки").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Контент вкладок
                    TabView(selection: $selectedTab) {
                        MeasurementsView(
                            viewModel: viewModel,
                            showingAddMeasurement: $showingAddMeasurement
                        )
                        .tag(0)
                        
                        DoctorQuestionsView(viewModel: viewModel)
                            .tag(1)
                        
                        SettingsView()
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                .padding(.vertical)
            }
            .navigationTitle("Профиль")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingEditProfile = true }) {
                        Image(systemName: "pencil")
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                if let info = viewModel.pregnancyInfo {
                    EditProfileView(viewModel: viewModel, info: info)
                }
            }
            .sheet(isPresented: $showingAddMeasurement) {
                AddMeasurementView(viewModel: viewModel)
            }
        }
    }
}

struct ProfileHeaderView: View {
    let info: PregnancyInfo?
    
    var body: some View {
        VStack(spacing: 15) {
            if let info = info {
                VStack(spacing: 10) {
                    Text("\(info.currentWeek) неделя")
                        .font(.title)
                        .bold()
                    
                    HStack(spacing: 20) {
                        InfoItem(title: "Вес", value: "\(Int(info.weight)) кг")
                        InfoItem(title: "Рост", value: "\(Int(info.height)) см")
                        InfoItem(title: "Группа крови", value: info.bloodType)
                    }
                    
                    Divider()
                    
                    HStack(spacing: 20) {
                        InfoItem(title: "Врач", value: info.doctorName)
                        InfoItem(title: "Клиника", value: info.hospitalName)
                    }
                }
            } else {
                Text("Добавьте информацию о беременности")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct InfoItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .bold()
        }
    }
}

struct MeasurementsChartView: View {
    let measurements: [Measurement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("График измерений")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(measurements) { measurement in
                    LineMark(
                        x: .value("Дата", measurement.date),
                        y: .value("Вес", measurement.weight)
                    )
                    .foregroundStyle(.pink)
                    
                    LineMark(
                        x: .value("Дата", measurement.date),
                        y: .value("Окружность", measurement.bellyCircumference)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .frame(height: 200)
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct MeasurementsView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @Binding var showingAddMeasurement: Bool
    
    var body: some View {
        VStack {
            if viewModel.measurements.isEmpty {
                EmptyStateView(
                    title: "Нет измерений",
                    message: "Добавьте свои измерения для отслеживания изменений",
                    buttonTitle: "Добавить измерение",
                    action: { showingAddMeasurement = true }
                )
            } else {
                List {
                    ForEach(viewModel.measurements.sorted(by: { $0.date > $1.date })) { measurement in
                        MeasurementRow(measurement: measurement)
                    }
                }
            }
        }
    }
}

struct MeasurementRow: View {
    let measurement: Measurement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(measurement.date, formatter: dateFormatter)
                .font(.headline)
            
            HStack {
                Text("Вес: \(String(format: "%.1f", measurement.weight)) кг")
                Spacer()
                Text("Окружность: \(String(format: "%.1f", measurement.bellyCircumference)) см")
            }
            .font(.subheadline)
            
            if let notes = measurement.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct DoctorQuestionsView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @State private var showingAddQuestion = false
    
    var body: some View {
        VStack {
            if viewModel.doctorQuestions.isEmpty {
                EmptyStateView(
                    title: "Нет вопросов",
                    message: "Добавьте вопросы, которые хотите задать врачу",
                    buttonTitle: "Добавить вопрос",
                    action: { showingAddQuestion = true }
                )
            } else {
                List {
                    ForEach(viewModel.doctorQuestions.sorted(by: { $0.date > $1.date })) { question in
                        DoctorQuestionRow(question: question)
                    }
                }
            }
        }
    }
}

struct DoctorQuestionRow: View {
    let question: DoctorQuestion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(question.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.pink.opacity(0.1))
                    .cornerRadius(8)
                
                Spacer()
                
                Text(question.date, formatter: dateFormatter)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(question.question)
                .font(.body)
            
            if let answer = question.answer {
                Text("Ответ: \(answer)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("reminderTime") private var reminderTime = Date()
    
    var body: some View {
        Form {
            Section(header: Text("Уведомления")) {
                Toggle("Включить уведомления", isOn: $notificationsEnabled)
                
                if notificationsEnabled {
                    DatePicker(
                        "Время напоминания",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                }
            }
            
            Section(header: Text("О приложении")) {
                HStack {
                    Text("Версия")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "plus.circle")
                .font(.system(size: 60))
                .foregroundColor(.pink)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: action) {
                Text(buttonTitle)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}() 