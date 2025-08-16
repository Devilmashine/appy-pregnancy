import SwiftUI

struct ChecklistView: View {
    @EnvironmentObject var viewModel: ChecklistViewModel
    @State private var selectedCategory: ChecklistCategory = .firstTrimester
    @State private var showingAddItem = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Категории
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ChecklistCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: category == selectedCategory,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
                
                // Список задач
                List {
                    ForEach(filteredItems) { item in
                        ChecklistItemRow(item: item) {
                            viewModel.toggleChecklistItem(item)
                        }
                    }
                    .onDelete(perform: viewModel.deleteChecklistItem)
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Чек-лист")
            .searchable(text: $searchText, prompt: "Поиск задач")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddChecklistItemView(category: selectedCategory)
                    .environmentObject(viewModel)
            }
        }
    }
    
    private var filteredItems: [ChecklistItem] {
        viewModel.checklistItems
            .filter { $0.category == selectedCategory }
            .filter { searchText.isEmpty ? true : $0.title.localizedCaseInsensitiveContains(searchText) }
    }
}

struct CategoryButton: View {
    let category: ChecklistCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.pink : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct ChecklistItemRow: View {
    let item: ChecklistItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .pink : .gray)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .strikethrough(item.isCompleted)
                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                
                if let dueDate = item.dueDate {
                    Text("Срок: \(dueDate, formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let notes = item.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddChecklistItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: ChecklistViewModel
    let category: ChecklistCategory
    
    @State private var title = ""
    @State private var notes = ""
    @State private var dueDate: Date?
    @State private var hasDueDate = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Задача")) {
                    TextField("Название задачи", text: $title)
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section(header: Text("Срок выполнения")) {
                    Toggle("Установить срок", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker(
                            "Срок",
                            selection: Binding(
                                get: { dueDate ?? Date() },
                                set: { dueDate = $0 }
                            ),
                            displayedComponents: [.date]
                        )
                    }
                }
                
                Section {
                    Button("Сохранить") {
                        saveItem()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle("Новая задача")
            .navigationBarItems(trailing: Button("Отмена") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func saveItem() {
        let item = ChecklistItem(
            id: UUID(),
            title: title,
            isCompleted: false,
            category: category,
            dueDate: hasDueDate ? dueDate : nil,
            notes: notes.isEmpty ? nil : notes
        )
        
        viewModel.addChecklistItem(item)
        presentationMode.wrappedValue.dismiss()
    }
}

// Предустановленные задачи для каждой категории
extension ChecklistCategory {
    var defaultItems: [String] {
        switch self {
        case .firstTrimester:
            return [
                "Записаться к гинекологу",
                "Сдать анализы крови",
                "Сделать УЗИ",
                "Начать принимать фолиевую кислоту",
                "Сообщить работодателю о беременности"
            ]
        case .secondTrimester:
            return [
                "Пройти скрининг",
                "Начать заниматься гимнастикой для беременных",
                "Выбрать курсы для будущих родителей",
                "Начать использовать крем от растяжек",
                "Составить список необходимых вещей"
            ]
        case .thirdTrimester:
            return [
                "Собрать сумку в роддом",
                "Выбрать роддом",
                "Подготовить детскую комнату",
                "Купить детскую кроватку",
                "Выбрать имя для малыша"
            ]
        case .hospitalBag:
            return [
                "Документы (паспорт, полис, обменная карта)",
                "Одежда для мамы",
                "Одежда для малыша",
                "Средства гигиены",
                "Телефон и зарядное устройство"
            ]
        case .babyItems:
            return [
                "Кроватка и матрас",
                "Коляска",
                "Автокресло",
                "Одежда для новорожденного",
                "Средства гигиены"
            ]
        case .homePreparation:
            return [
                "Сделать ремонт в детской",
                "Купить стиральную машину",
                "Подготовить аптечку",
                "Установить детское кресло в машину",
                "Подготовить место для кормления"
            ]
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()
