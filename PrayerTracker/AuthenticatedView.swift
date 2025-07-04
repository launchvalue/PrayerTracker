
import SwiftUI
import SwiftData

struct AuthenticatedView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    var body: some View {
        if let profile = profiles.first {
            AppTabView(profile: profile)
                .environment(StatsService(modelContext: modelContext))
        } else {
            OnboardingView()
                .environment(\.modelContext, modelContext)
        }
    }
}
