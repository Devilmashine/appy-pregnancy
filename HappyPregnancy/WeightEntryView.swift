//
//  WeightEntryView.swift
//  Happy Pregnancy
//
//  Created by Федянин Александр on 29.05.2023.
//

import SwiftUI
import CoreData

struct WeightEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var bellyCircumference: String = ""
    @State var weight: String = ""

    var body: some View {
        VStack {
            TextField("Окружность живота", text: $bellyCircumference)
            TextField("Вес", text: $weight)
            Button(action: {
                let newMeasurement = MeasurementEntity(context: viewContext)
                newMeasurement.bellyCircumference = Double(bellyCircumference) ?? 0.0
                newMeasurement.weight = Double(weight) ?? 0.0
                do {
                    try viewContext.save()
                } catch {
                    print("Ошибка сохранения: \(error.localizedDescription)")
                }
            }) {
                Text("Сохранить")
            }

        }
    }
}
