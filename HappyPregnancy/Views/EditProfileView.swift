import SwiftUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: PregnancyInfoViewModel

    @State private var info: PregnancyInfo

    init(info: PregnancyInfo) {
        _info = State(initialValue: info)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    DatePicker("Начало беременности", selection: $info.startDate, displayedComponents: .date)
                    DatePicker("Предполагаемая дата родов", selection: $info.dueDate, displayedComponents: .date)
                    Stepper("Текущая неделя: \(info.currentWeek)", value: $info.currentWeek, in: 1...42)
                }

                Section(header: Text("Медицинская информация")) {
                    TextField("Группа крови", text: $info.bloodType)
                    TextField("Врач", text: $info.doctorName)
                    TextField("Клиника", text: $info.hospitalName)
                }

                Section(header: Text("Физические параметры")) {
                    HStack {
                        Text("Вес (кг)")
                        Spacer()
                        TextField("Вес", value: $info.weight, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("Рост (см)")
                        Spacer()
                        TextField("Рост", value: $info.height, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    }
                }
            }
            .navigationTitle("Редактировать профиль")
            .navigationBarItems(
                leading: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Сохранить") {
                    viewModel.savePregnancyInfo(info)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
