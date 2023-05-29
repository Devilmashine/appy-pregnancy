//
//  Happy_PregnasyApp.swift
//  Happy Pregnasy
//
//  Created by Федянин Александр on 29.05.2023.
//

import SwiftUI

@main
struct Happy_PregnasyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
