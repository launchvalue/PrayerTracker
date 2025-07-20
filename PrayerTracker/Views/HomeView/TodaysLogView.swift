import SwiftUI
import SwiftData

struct TodaysLogView: View {
    let todaysLog: DailyLog?
    let isLoading: Bool
    let error: Error?
    @Bindable var prayerDebt: PrayerDebt
    let userProfile: UserProfile
    let onPrayerUpdate: (String, DailyLog, UserProfile) -> Void
    let onRetry: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Text("Today's Log")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let todayLog = todaysLog {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(todayLog.prayersCompleted)/\(userProfile.dailyGoal)")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Text("prayers completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            
            // Content
            if isLoading {
                LoadingStateView()
            } else if let error = error {
                ErrorStateView(error: error, onRetry: onRetry)
            } else if let todayLog = todaysLog {
                PrayerCardsView(
                    todaysLog: todayLog,
                    prayerDebt: prayerDebt,
                    userProfile: userProfile,
                    onPrayerUpdate: onPrayerUpdate
                )
            } else {
                EmptyStateView(onRetry: onRetry)
            }
        }
    }
}

// MARK: - Supporting Views

private struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading today's log...")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 16)
    }
}

private struct ErrorStateView: View {
    let error: Error
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(.orange)
            
            Text("Failed to Load Today's Log")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 16)
    }
}

private struct EmptyStateView: View {
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 32))
                .foregroundColor(.blue)
            
            Text("No Log Found")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Unable to find or create today's prayer log.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Create Log") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 16)
    }
}

// Previews temporarily disabled due to SwiftData model dependencies
// #Preview("Loading") {
//     TodaysLogView(
//         todaysLog: nil,
//         isLoading: true,
//         error: nil,
//         prayerDebt: .constant(samplePrayerDebt),
//         userProfile: sampleUserProfile,
//         onPrayerUpdate: { _, _, _ in },
//         onRetry: { }
//     )
// }
//
// #Preview("Error") {
//     TodaysLogView(
//         todaysLog: nil,
//         isLoading: false,
//         error: NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create daily log"]),
//         prayerDebt: .constant(samplePrayerDebt),
//         userProfile: sampleUserProfile,
//         onPrayerUpdate: { _, _, _ in },
//         onRetry: { }
//     )
// }
//
// #Preview("Empty") {
//     TodaysLogView(
//         todaysLog: nil,
//         isLoading: false,
//         error: nil,
//         prayerDebt: .constant(samplePrayerDebt),
//         userProfile: sampleUserProfile,
//         onPrayerUpdate: { _, _, _ in },
//         onRetry: { }
//     )
// }
