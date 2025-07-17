import SwiftUI
import SwiftData

struct WeeklyProgressView: View {
    let userProfile: UserProfile
    let currentWeekLogs: [DailyLog]
    
    private var prayersMadeUpThisWeek: Int {
        currentWeekLogs.reduce(0) { $0 + $1.prayersCompleted }
    }
    
    private var progress: Double {
        guard userProfile.weeklyGoal > 0 else { return 0 }
        return Double(prayersMadeUpThisWeek) / Double(userProfile.weeklyGoal)
    }
    
    var body: some View {
        WeeklyProgressCapsuleView(
            dailyGoal: userProfile.dailyGoal,
            weeklyLogs: currentWeekLogs
        )
        .padding(.horizontal, 16)
    }
}

// Preview temporarily disabled due to SwiftData model dependencies
// #Preview {
//     WeeklyProgressView(
//         userProfile: sampleUserProfile,
//         currentWeekLogs: sampleWeeklyLogs
//     )
// }
