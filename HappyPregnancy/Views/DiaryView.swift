import SwiftUI
import PhotosUI

struct DiaryView: View {
    @EnvironmentObject var viewModel: DiaryViewModel
    @State private var showingAddEntry = false
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                // Календарь для выбора даты
                DatePicker("Выберите дату",
                          selection: $selectedDate,
                          displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .padding()
                
                // Список записей за выбранную дату
                List {
                    ForEach(filteredEntries) { entry in
                        DiaryEntryRow(entry: entry)
                    }
                    .onDelete(perform: viewModel.deleteDiaryEntry)
                }
            }
            .navigationTitle("Дневник")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEntry = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddDiaryEntryView(date: selectedDate)
                    .environmentObject(viewModel)
            }
        }
    }
    
    private var filteredEntries: [DiaryEntry] {
        viewModel.diaryEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
}

struct DiaryEntryRow: View {
    let entry: DiaryEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.date, formatter: timeFormatter)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                MoodView(mood: entry.mood)
            }
            
            if !entry.symptoms.isEmpty {
                Text("Симптомы: \(entry.symptoms.joined(separator: ", "))")
                    .font(.subheadline)
            }
            
            Text(entry.notes)
                .font(.body)
            
            if let photos = entry.photos, !photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(photos, id: \.self) { photoData in
                            if let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct MoodView: View {
    let mood: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= mood ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            }
        }
    }
}

struct AddDiaryEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: DiaryViewModel
    let date: Date
    
    @State private var mood: Int = 3
    @State private var symptoms: [String] = []
    @State private var notes: String = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var loadedPhotos: [Data] = []
    
    private let commonSymptoms = [
        "Тошнота", "Головная боль", "Усталость", "Боли в спине",
        "Изжога", "Отеки", "Судороги", "Бессонница"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Настроение")) {
                    HStack {
                        Text("Оценка")
                        Spacer()
                        MoodView(mood: mood)
                            .onTapGesture {
                                mood = min(mood + 1, 5)
                            }
                    }
                }
                
                Section(header: Text("Симптомы")) {
                    ForEach(commonSymptoms, id: \.self) { symptom in
                        Toggle(symptom, isOn: Binding(
                            get: { symptoms.contains(symptom) },
                            set: { isSelected in
                                if isSelected {
                                    symptoms.append(symptom)
                                } else {
                                    symptoms.removeAll { $0 == symptom }
                                }
                            }
                        ))
                    }
                }
                
                Section(header: Text("Заметки")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section(header: Text("Фотографии")) {
                    PhotosPicker(selection: $selectedPhotos,
                               matching: .images) {
                        Label("Выбрать фото", systemImage: "photo")
                    }
                    
                    if !loadedPhotos.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(loadedPhotos, id: \.self) { photoData in
                                    if let uiImage = UIImage(data: photoData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Новая запись")
            .navigationBarItems(
                leading: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Сохранить") {
                    saveEntry()
                }
            )
            .onChange(of: selectedPhotos) { newValue in
                Task {
                    loadedPhotos = []
                    for item in newValue {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            loadedPhotos.append(data)
                        }
                    }
                }
            }
        }
    }
    
    private func saveEntry() {
        let entry = DiaryEntry(
            id: UUID(),
            date: date,
            mood: mood,
            symptoms: symptoms,
            notes: notes,
            photos: loadedPhotos
        )
        
        viewModel.addDiaryEntry(entry)
        presentationMode.wrappedValue.dismiss()
    }
}

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()
