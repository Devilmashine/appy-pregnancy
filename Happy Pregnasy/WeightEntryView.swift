//
//  WeightEntryView.swift
//  Happy Pregnasy
//
//  Created by Федянин Александр on 29.05.2023.
//

import SwiftUI

struct WeightEntryView: View {
    @State var height: String = ""
    @State var weight: String = ""

    var body: some View {
        VStack {
            TextField("Рост", text: $height)
            TextField("Вес", text: $weight)
            Button(action: {
                let newWeightEntry = WeightEntry(context: managedObjectContext)
                newWeightEntry.height = Float(height) ?? 0.0
                newWeightEntry.weight = Float(weight) ?? 0.0
                newWeightEntry.date = Date()
                do {
                    try managedObjectContext.save()
                } catch {
                    print("Ошибка сохранения: \(error.localizedDescription)")
                }
            }) {
                Text("Сохранить")
            }

        }
    }
}

