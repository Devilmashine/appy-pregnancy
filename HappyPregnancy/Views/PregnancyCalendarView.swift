import SwiftUI

struct PregnancyCalendarView: View {
    @EnvironmentObject var viewModel: PregnancyInfoViewModel

    var body: some View {
        NavigationView {
            VStack {
                if let info = viewModel.pregnancyInfo {
                    Text("Current week: \(info.currentWeek)")
                    // The rest of the view will be implemented later
                } else {
                    Text("Please set up your pregnancy info in the Profile tab.")
                }
            }
            .navigationTitle("Календарь")
        }
    }
}
