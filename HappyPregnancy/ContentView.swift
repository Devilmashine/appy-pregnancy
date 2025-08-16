//
//  ContentView.swift
//  Happy Pregnancy
//
//  Created by Федянин Александр on 29.05.2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView {
            CalendarView()
                .tabItem {
                    Label("Календарь", systemImage: "calendar")
                }
            
            DiaryView()
                .tabItem {
                    Label("Дневник", systemImage: "book.fill")
                }
            
            KicksCounterView()
                .tabItem {
                    Label("Шевеления", systemImage: "heart.fill")
                }
            
            ChecklistView()
                .tabItem {
                    Label("Чек-лист", systemImage: "checklist")
                }
            
            ProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person.fill")
                }
        }
    }
}

struct CalendarView: View {
    var body: some View {
        NavigationView {
            Text("Календарь беременности")
                .navigationTitle("Календарь")
        }
    }
}

struct DiaryView: View {
    var body: some View {
        NavigationView {
            Text("Дневник самочувствия")
                .navigationTitle("Дневник")
        }
    }
}

struct KicksCounterView: View {
    var body: some View {
        NavigationView {
            Text("Счетчик шевелений")
                .navigationTitle("Шевеления")
        }
    }
}

struct ChecklistView: View {
    var body: some View {
        NavigationView {
            Text("Чек-лист")
                .navigationTitle("Чек-лист")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            Text("Профиль")
                .navigationTitle("Профиль")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
