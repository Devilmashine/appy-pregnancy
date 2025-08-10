import SwiftUI

struct AddDoctorQuestionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: DoctorQuestionViewModel

    @State private var question: String = ""
    @State private var category: QuestionCategory = .general
    @State private var date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Вопрос")) {
                    TextEditor(text: $question)
                        .frame(height: 100)
                }

                Section(header: Text("Категория")) {
                    Picker("Категория", selection: $category) {
                        ForEach(QuestionCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }

                Section(header: Text("Дата")) {
                    DatePicker("Дата", selection: $date, displayedComponents: .date)
                }

                Section {
                    Button("Сохранить") {
                        saveQuestion()
                    }
                    .disabled(question.isEmpty)
                }
            }
            .navigationTitle("Новый вопрос")
            .navigationBarItems(trailing: Button("Отмена") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func saveQuestion() {
        let newQuestion = DoctorQuestion(
            id: UUID(),
            question: question,
            isAnswered: false,
            answer: nil,
            date: date,
            category: category
        )

        viewModel.addDoctorQuestion(newQuestion)
        presentationMode.wrappedValue.dismiss()
    }
}
