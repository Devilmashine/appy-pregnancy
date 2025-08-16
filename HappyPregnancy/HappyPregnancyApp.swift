//
//  HappyPregnancyApp.swift
//  Happy Pregnancy
//
//  Created by Федянин Александр on 29.05.2023.
//

import SwiftUI

@main
struct HappyPregnancyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
