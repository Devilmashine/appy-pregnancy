import SwiftUI

struct KicksCounterView: View {
    @EnvironmentObject var viewModel: KicksCounterViewModel
    @State private var isCounting = false
    @State private var startTime: Date?
    @State private var kicksCount = 0
    @State private var showingSaveSession = false
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Статистика за сегодня
                TodayStatsView(sessions: viewModel.getKicksForToday())
                
                // Основной счетчик
                VStack(spacing: 30) {
                    Text("\(kicksCount)")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundColor(.pink)
                    
                    Text("шевелений")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    if let startTime = startTime {
                        Text(timerString(from: startTime))
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        if isCounting {
                            showingSaveSession = true
                        } else {
                            startCounting()
                        }
                    }) {
                        Text(isCounting ? "Завершить" : "Начать подсчет")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 60)
                            .background(isCounting ? Color.red : Color.pink)
                            .cornerRadius(30)
                    }
                    
                    if isCounting {
                        Button(action: incrementKicks) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.pink)
                                .frame(width: 100, height: 100)
                                .background(Color.pink.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(radius: 5)
                
                // История сессий
                List {
                    ForEach(viewModel.kicksSessions.sorted(by: { $0.date > $1.date })) { session in
                        KicksSessionRow(session: session)
                    }
                    .onDelete(perform: viewModel.deleteKicksSession)
                }
            }
            .padding()
            .navigationTitle("Шевеления")
            .sheet(isPresented: $showingSaveSession) {
                SaveKicksSessionView(
                    kicksCount: kicksCount,
                    startTime: startTime ?? Date(),
                    notes: $notes
                ) {
                    resetCounter()
                }
                .environmentObject(viewModel)
            }
        }
    }
    
    private func startCounting() {
        isCounting = true
        startTime = Date()
        kicksCount = 0
    }
    
    private func incrementKicks() {
        kicksCount += 1
    }
    
    private func resetCounter() {
        isCounting = false
        startTime = nil
        kicksCount = 0
        notes = ""
    }
    
    private func timerString(from startTime: Date) -> String {
        let timeInterval = Date().timeIntervalSince(startTime)
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct TodayStatsView: View {
    let sessions: [KicksSession]
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Статистика за сегодня")
                .font(.headline)
            
            HStack(spacing: 20) {
                StatView(title: "Сессии", value: "\(sessions.count)")
                StatView(title: "Всего шевелений", value: "\(sessions.reduce(0) { $0 + $1.kicksCount })")
                StatView(title: "Среднее время", value: averageTimeString)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var averageTimeString: String {
        guard !sessions.isEmpty else { return "0:00" }
        let totalSeconds = sessions.reduce(0) { $0 + $1.duration }
        let averageSeconds = totalSeconds / Double(sessions.count)
        let minutes = Int(averageSeconds) / 60
        let seconds = Int(averageSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .bold()
        }
    }
}

struct KicksSessionRow: View {
    let session: KicksSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.date, formatter: dateFormatter)
                    .font(.headline)
                Spacer()
                Text("\(session.kicksCount) шевелений")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Длительность: \(formatDuration(session.duration))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let notes = session.notes {
                    Text("•")
                    Text(notes)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct SaveKicksSessionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: KicksCounterViewModel
    
    let kicksCount: Int
    let startTime: Date
    @Binding var notes: String
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Результаты")) {
                    HStack {
                        Text("Количество шевелений")
                        Spacer()
                        Text("\(kicksCount)")
                            .bold()
                    }
                    
                    HStack {
                        Text("Длительность")
                        Spacer()
                        Text(formatDuration(Date().timeIntervalSince(startTime)))
                            .bold()
                    }
                }
                
                Section(header: Text("Заметки")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Сохранить сессию")
            .navigationBarItems(
                leading: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Сохранить") {
                    saveSession()
                }
            )
        }
    }
    
    private func saveSession() {
        let session = KicksSession(
            id: UUID(),
            date: startTime,
            duration: Date().timeIntervalSince(startTime),
            kicksCount: kicksCount,
            notes: notes.isEmpty ? nil : notes
        )
        
        viewModel.addKicksSession(session)
        onSave()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
