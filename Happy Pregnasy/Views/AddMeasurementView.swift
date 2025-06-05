import SwiftUI

struct AddMeasurementView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: PregnancyViewModel
    
    @State private var weight: String = ""
    @State private var bellyCircumference: String = ""
    @State private var notes: String = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Измерения")) {
                    TextField("Вес (кг)", text: $weight)
                        .keyboardType(.decimalPad)
                    TextField("Окружность живота (см)", text: $bellyCircumference)
                        .keyboardType(.decimalPad)
                    DatePicker("Дата", selection: $date, displayedComponents: [.date])
                }
                
                Section(header: Text("Заметки")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button("Сохранить") {
                        saveMeasurement()
                    }
                    .disabled(weight.isEmpty || bellyCircumference.isEmpty)
                }
            }
            .navigationTitle("Новое измерение")
            .navigationBarItems(trailing: Button("Отмена") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func saveMeasurement() {
        let measurement = Measurement(
            id: UUID(),
            date: date,
            weight: Double(weight) ?? 0,
            bellyCircumference: Double(bellyCircumference) ?? 0,
            notes: notes.isEmpty ? nil : notes
        )
        
        viewModel.addMeasurement(measurement)
        presentationMode.wrappedValue.dismiss()
    }
} 