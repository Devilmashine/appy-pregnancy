import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = PregnancyViewModel()
    
    var body: some View {
        TabView {
            // Основные разделы
            Group {
                PregnancyCalendarView(viewModel: viewModel)
                    .tabItem {
                        Label("Календарь", systemImage: "calendar")
                    }
                
                WellnessDiaryView(viewModel: viewModel)
                    .tabItem {
                        Label("Дневник", systemImage: "book.fill")
                    }
                
                KicksCounterView(viewModel: viewModel)
                    .tabItem {
                        Label("Шевеления", systemImage: "heart.fill")
                    }
            }
            
            // Новые разделы
            Group {
                NutritionView(viewModel: viewModel)
                    .tabItem {
                        Label("Питание", systemImage: "fork.knife")
                    }
                
                ExercisesView(viewModel: viewModel)
                    .tabItem {
                        Label("Упражнения", systemImage: "figure.walk")
                    }
                
                SleepView(viewModel: viewModel)
                    .tabItem {
                        Label("Сон", systemImage: "moon.zzz.fill")
                    }
                
                BirthPreparationView(viewModel: viewModel)
                    .tabItem {
                        Label("Роды", systemImage: "heart.circle.fill")
                    }
                
                BabyView(viewModel: viewModel)
                    .tabItem {
                        Label("Малыш", systemImage: "baby.fill")
                    }
            }
            
            // Дополнительные разделы
            Group {
                CalculatorsView(viewModel: viewModel)
                    .tabItem {
                        Label("Калькуляторы", systemImage: "function")
                    }
                
                MedicalTestsView(viewModel: viewModel)
                    .tabItem {
                        Label("Анализы", systemImage: "cross.case.fill")
                    }
                
                ChecklistView(viewModel: viewModel)
                    .tabItem {
                        Label("Чек-лист", systemImage: "checklist")
                    }
                
                ProfileView(viewModel: viewModel)
                    .tabItem {
                        Label("Профиль", systemImage: "person.fill")
                    }
            }
        }
        .accentColor(.pink) // Основной цвет приложения
        .onAppear {
            // Настройка внешнего вида табов
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Предварительный просмотр
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 