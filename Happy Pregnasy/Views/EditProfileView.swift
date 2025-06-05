import SwiftUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: PregnancyViewModel
    let info: PregnancyInfo
    
    @State private var weight: String
    @State private var height: String
    @State private var bloodType: String
    @State private var doctorName: String
    @State private var hospitalName: String
    
    init(viewModel: PregnancyViewModel, info: PregnancyInfo) {
        self.viewModel = viewModel
        self.info = info
        _weight = State(initialValue: String(format: "%.1f", info.weight))
        _height = State(initialValue: String(format: "%.1f", info.height))
        _bloodType = State(initialValue: info.bloodType)
        _doctorName = State(initialValue: info.doctorName)
        _hospitalName = State(initialValue: info.hospitalName)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
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
                        saveProfile()
                    }
                }
            }
            .navigationTitle("Редактировать профиль")
            .navigationBarItems(trailing: Button("Отмена") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func saveProfile() {
        let updatedInfo = PregnancyInfo(
            id: info.id,
            startDate: info.startDate,
            dueDate: info.dueDate,
            currentWeek: info.currentWeek,
            weight: Double(weight) ?? info.weight,
            height: Double(height) ?? info.height,
            bloodType: bloodType,
            doctorName: doctorName,
            hospitalName: hospitalName
        )
        
        viewModel.pregnancyInfo = updatedInfo
        presentationMode.wrappedValue.dismiss()
    }
} 