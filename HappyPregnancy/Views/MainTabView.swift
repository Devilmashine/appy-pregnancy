import SwiftUI

struct MainTabView: View {
    @StateObject private var pregnancyInfoViewModel = PregnancyInfoViewModel()
    @StateObject private var diaryViewModel = DiaryViewModel()
    @StateObject private var kicksCounterViewModel = KicksCounterViewModel()
    @StateObject private var checklistViewModel = ChecklistViewModel()
    // ... other view models will be added here
    
    var body: some View {
        TabView {
            // Основные разделы
            Group {
                PregnancyCalendarView()
                    .environmentObject(pregnancyInfoViewModel)
                    .tabItem {
                        Label("Календарь", systemImage: "calendar")
                    }
                
                // I will need to create this view
                // WellnessDiaryView(viewModel: diaryViewModel)
                DiaryView()
                    .environmentObject(diaryViewModel)
                    .tabItem {
                        Label("Дневник", systemImage: "book.fill")
                    }
                
                KicksCounterView()
                    .environmentObject(kicksCounterViewModel)
                    .tabItem {
                        Label("Шевеления", systemImage: "heart.fill")
                    }
            }
            
            // Новые разделы
            Group {
                NutritionView()
                    .tabItem {
                        Label("Питание", systemImage: "fork.knife")
                    }
                
                ExercisesView()
                    .tabItem {
                        Label("Упражнения", systemImage: "figure.walk")
                    }
                
                SleepView()
                    .tabItem {
                        Label("Сон", systemImage: "moon.zzz.fill")
                    }
                
                BirthPreparationView()
                    .tabItem {
                        Label("Роды", systemImage: "heart.circle.fill")
                    }
                
                BabyView()
                    .tabItem {
                        Label("Малыш", systemImage: "baby.fill")
                    }
            }
            
            // Дополнительные разделы
            Group {
                CalculatorsView()
                    .tabItem {
                        Label("Калькуляторы", systemImage: "function")
                    }
                
                MedicalTestsView()
                    .tabItem {
                        Label("Анализы", systemImage: "cross.case.fill")
                    }
                
                ChecklistView()
                    .environmentObject(checklistViewModel)
                    .tabItem {
                        Label("Чек-лист", systemImage: "checklist")
                    }
                
                // ProfileView(viewModel: pregnancyInfoViewModel)
                ProfileView()
                    .environmentObject(pregnancyInfoViewModel)
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
