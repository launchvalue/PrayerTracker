
import SwiftUI
import SwiftData

struct AuthenticatedView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        let currentUserID = authManager.currentUserID ?? "default"
        
        // Use user-specific query to ensure data isolation
        UserSpecificContentView(userID: currentUserID)
            .environment(StatsService(modelContext: modelContext, userID: currentUserID))
    }
}

// Separate view to handle user-specific queries
struct UserSpecificContentView: View {
    let userID: String
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    init(userID: String) {
        self.userID = userID
        
        // Filter profiles by user ID for true data isolation
        self._profiles = Query(
            filter: #Predicate<UserProfile> { profile in
                profile.userID == userID
            },
            sort: \.name
        )
    }
    
    var body: some View {
        if let profile = profiles.first {
            AppTabView(profile: profile)
        } else {
            OnboardingView(userID: userID)
                .environment(\.modelContext, modelContext)
        }
    }
}
