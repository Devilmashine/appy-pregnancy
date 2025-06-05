import SwiftUI
import Charts

struct SleepView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @State private var selectedTab = 0
    @State private var showingAddSleep = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Сегментированный контрол для переключения между вкладками
                Picker("", selection: $selectedTab) {
                    Text("Статистика").tag(0)
                    Text("История").tag(1)
                    Text("Советы").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Контент в зависимости от выбранной вкладки
                TabView(selection: $selectedTab) {
                    // Вкладка статистики
                    SleepStatsView(viewModel: viewModel)
                        .tag(0)
                    
                    // Вкладка истории
                    SleepHistoryView(viewModel: viewModel)
                        .tag(1)
                    
                    // Вкладка советов
                    SleepTipsView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Сон")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddSleep = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSleep) {
                AddSleepView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Статистика сна
struct SleepStatsView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Средняя продолжительность сна
                StatCard(
                    title: "Средняя продолжительность",
                    value: "\(Int(averageSleepDuration)) ч",
                    icon: "moon.zzz.fill",
                    color: .purple
                )
                
                // Качество сна
                StatCard(
                    title: "Качество сна",
                    value: "\(Int(averageSleepQuality))%",
                    icon: "star.fill",
                    color: .yellow
                )
                
                // График сна за неделю
                VStack(alignment: .leading) {
                    Text("Сон за неделю")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart {
                        ForEach(weeklySleepData) { data in
                            BarMark(
                                x: .value("День", data.date, unit: .day),
                                y: .value("Часы", data.duration)
                            )
                            .foregroundStyle(Color.purple.gradient)
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
            .padding(.vertical)
        }
    }
    
    private var averageSleepDuration: Double {
        let totalDuration = viewModel.sleepEntries.reduce(0) { $0 + $1.duration }
        return totalDuration / Double(max(viewModel.sleepEntries.count, 1))
    }
    
    private var averageSleepQuality: Double {
        let totalQuality = viewModel.sleepEntries.reduce(0) { $0 + $1.quality }
        return totalQuality / Double(max(viewModel.sleepEntries.count, 1))
    }
    
    private var weeklySleepData: [SleepDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
        
        return viewModel.sleepEntries
            .filter { $0.date >= weekAgo }
            .map { SleepDataPoint(date: $0.date, duration: $0.duration) }
    }
}

struct SleepDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let duration: Double
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title2)
                    .bold()
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

// MARK: - История сна
struct SleepHistoryView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack {
            // Выбор даты
            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
            
            // Список записей сна
            List {
                ForEach(filteredSleepEntries) { entry in
                    SleepEntryRowView(entry: entry)
                }
            }
        }
    }
    
    private var filteredSleepEntries: [SleepEntry] {
        viewModel.sleepEntries.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
}

struct SleepEntryRowView: View {
    let entry: SleepEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.date, style: .time)
                    .font(.headline)
                
                Spacer()
                
                Text("\(Int(entry.duration)) ч")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                ForEach(0..<5) { index in
                    Image(systemName: index < entry.quality / 20 ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }
            }
            
            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Советы по сну
struct SleepTipsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(sleepTips) { tip in
                    TipCard(tip: tip)
                }
            }
            .padding()
        }
    }
}

struct TipCard: View {
    let tip: SleepTip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: tip.icon)
                    .font(.title2)
                    .foregroundColor(tip.color)
                
                Text(tip.title)
                    .font(.headline)
            }
            
            Text(tip.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Добавление записи сна
struct AddSleepView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var quality = 3
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Время сна")) {
                    DatePicker("Время засыпания", selection: $startTime, displayedComponents: [.hourAndMinute])
                    DatePicker("Время пробуждения", selection: $endTime, displayedComponents: [.hourAndMinute])
                }
                
                Section(header: Text("Качество сна")) {
                    HStack {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= quality ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .onTapGesture {
                                    quality = index
                                }
                        }
                    }
                }
                
                Section(header: Text("Примечания")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Новая запись")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveSleepEntry()
                    }
                }
            }
        }
    }
    
    private func saveSleepEntry() {
        let duration = endTime.timeIntervalSince(startTime) / 3600 // конвертируем в часы
        
        let entry = SleepEntry(
            id: UUID(),
            date: startTime,
            duration: duration,
            quality: Double(quality * 20), // конвертируем в проценты
            notes: notes
        )
        
        viewModel.addSleepEntry(entry)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Модели данных
struct SleepTip: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
}

let sleepTips = [
    SleepTip(
        title: "Правильная поза для сна",
        description: "Спите на левом боку с подушкой между коленями для лучшего кровообращения.",
        icon: "bed.double.fill",
        color: .blue
    ),
    SleepTip(
        title: "Режим сна",
        description: "Старайтесь ложиться и вставать в одно и то же время каждый день.",
        icon: "clock.fill",
        color: .orange
    ),
    SleepTip(
        title: "Комфортная температура",
        description: "Поддерживайте температуру в спальне 18-20°C для оптимального сна.",
        icon: "thermometer",
        color: .red
    ),
    SleepTip(
        title: "Вечерний ритуал",
        description: "Создайте расслабляющий ритуал перед сном: теплая ванна, чтение книги.",
        icon: "moon.stars.fill",
        color: .purple
    )
] 