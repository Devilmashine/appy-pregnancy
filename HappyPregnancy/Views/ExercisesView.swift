import SwiftUI
import AVKit

struct ExercisesView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @State private var selectedTab = 0
    @State private var showingAddExercise = false
    @State private var showingAddSession = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Сегментированный контрол для переключения между вкладками
                Picker("", selection: $selectedTab) {
                    Text("Упражнения").tag(0)
                    Text("История").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Контент в зависимости от выбранной вкладки
                TabView(selection: $selectedTab) {
                    // Вкладка упражнений
                    ExercisesListView(viewModel: viewModel)
                        .tag(0)
                    
                    // Вкладка истории
                    ExerciseHistoryView(viewModel: viewModel)
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Упражнения")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        switch selectedTab {
                        case 0: showingAddExercise = true
                        case 1: showingAddSession = true
                        default: break
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingAddSession) {
                AddExerciseSessionView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Список упражнений
struct ExercisesListView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @State private var selectedTrimester = 1
    @State private var selectedDifficulty: Exercise.Difficulty?
    
    var body: some View {
        VStack {
            // Фильтры
            HStack {
                Picker("Триместр", selection: $selectedTrimester) {
                    Text("1").tag(1)
                    Text("2").tag(2)
                    Text("3").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Picker("Сложность", selection: $selectedDifficulty) {
                    Text("Все").tag(nil as Exercise.Difficulty?)
                    ForEach(Exercise.Difficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.rawValue).tag(difficulty as Exercise.Difficulty?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding()
            
            // Список упражнений
            List {
                ForEach(filteredExercises) { exercise in
                    NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                        ExerciseRowView(exercise: exercise)
                    }
                }
            }
        }
    }
    
    private var filteredExercises: [Exercise] {
        viewModel.exercises.filter { exercise in
            exercise.trimester == selectedTrimester &&
            (selectedDifficulty == nil || exercise.difficulty == selectedDifficulty)
        }
    }
}

struct ExerciseRowView: View {
    let exercise: Exercise
    
    var body: some View {
        HStack {
            if let imageURL = exercise.imageURL {
                AsyncImage(url: imageURL) { image in
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
                Text(exercise.name)
                    .font(.headline)
                
                HStack {
                    Text(exercise.difficulty.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(exercise.duration / 60)) мин")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ExerciseDetailView: View {
    let exercise: Exercise
    @State private var player: AVPlayer?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let videoURL = exercise.videoURL {
                    VideoPlayer(player: player)
                        .frame(height: 200)
                        .onAppear {
                            player = AVPlayer(url: videoURL)
                        }
                }
                
                if let imageURL = exercise.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(maxHeight: 200)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Описание")
                        .font(.headline)
                    
                    Text(exercise.description)
                        .font(.body)
                }
                .padding()
                
                HStack {
                    Label("\(Int(exercise.duration / 60)) мин", systemImage: "clock")
                    Spacer()
                    Label(exercise.difficulty.rawValue, systemImage: "figure.walk")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle(exercise.name)
    }
}

// MARK: - История упражнений
struct ExerciseHistoryView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack {
            // Выбор даты
            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
            
            // Список тренировок
            List {
                ForEach(filteredSessions) { session in
                    ExerciseSessionRowView(session: session)
                }
            }
        }
    }
    
    private var filteredSessions: [ExerciseSession] {
        viewModel.exerciseSessions.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
}

struct ExerciseSessionRowView: View {
    let session: ExerciseSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(session.exercise.name)
                .font(.headline)
            
            HStack {
                Label("\(Int(session.duration / 60)) мин", systemImage: "clock")
                Spacer()
                Label("\(Int(session.caloriesBurned)) ккал", systemImage: "flame")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            if !session.notes.isEmpty {
                Text(session.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Добавление упражнения
struct AddExerciseView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var description = ""
    @State private var duration = ""
    @State private var difficulty: Exercise.Difficulty = .easy
    @State private var trimester = 1
    @State private var videoURL: URL?
    @State private var imageURL: URL?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Название", text: $name)
                    
                    TextEditor(text: $description)
                        .frame(height: 100)
                    
                    TextField("Длительность (минуты)", text: $duration)
                        .keyboardType(.numberPad)
                    
                    Picker("Сложность", selection: $difficulty) {
                        ForEach(Exercise.Difficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                    
                    Picker("Триместр", selection: $trimester) {
                        Text("Первый").tag(1)
                        Text("Второй").tag(2)
                        Text("Третий").tag(3)
                    }
                }
                
                Section(header: Text("Медиа")) {
                    // TODO: Добавить загрузку видео и изображений
                    Text("Загрузка медиафайлов")
                }
            }
            .navigationTitle("Новое упражнение")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveExercise()
                    }
                    .disabled(name.isEmpty || description.isEmpty || duration.isEmpty)
                }
            }
        }
    }
    
    private func saveExercise() {
        guard let durationValue = Double(duration) else { return }
        
        let exercise = Exercise(
            id: UUID(),
            name: name,
            description: description,
            duration: durationValue * 60, // конвертируем минуты в секунды
            difficulty: difficulty,
            trimester: trimester,
            videoURL: videoURL,
            imageURL: imageURL
        )
        
        viewModel.addExercise(exercise)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Добавление тренировки
struct AddExerciseSessionView: View {
    @ObservedObject var viewModel: PregnancyViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedExercise: Exercise?
    @State private var duration = ""
    @State private var caloriesBurned = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Упражнение")) {
                    Picker("Выберите упражнение", selection: $selectedExercise) {
                        Text("Выберите").tag(nil as Exercise?)
                        ForEach(viewModel.exercises) { exercise in
                            Text(exercise.name).tag(exercise as Exercise?)
                        }
                    }
                }
                
                Section(header: Text("Детали тренировки")) {
                    TextField("Длительность (минуты)", text: $duration)
                        .keyboardType(.numberPad)
                    
                    TextField("Сожжено калорий", text: $caloriesBurned)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Примечания")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Новая тренировка")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveSession()
                    }
                    .disabled(selectedExercise == nil || duration.isEmpty || caloriesBurned.isEmpty)
                }
            }
        }
    }
    
    private func saveSession() {
        guard let exercise = selectedExercise,
              let durationValue = Double(duration),
              let caloriesValue = Double(caloriesBurned) else { return }
        
        let session = ExerciseSession(
            id: UUID(),
            date: Date(),
            exercise: exercise,
            duration: durationValue * 60, // конвертируем минуты в секунды
            caloriesBurned: caloriesValue,
            notes: notes
        )
        
        viewModel.addExerciseSession(session)
        presentationMode.wrappedValue.dismiss()
    }
} 