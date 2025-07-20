
import SwiftUI
import SwiftData
import Foundation

struct AuthenticatedView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthenticationManager.self) private var authManager
    @State private var statsService: StatsService?
    
    var body: some View {
        let currentUserID = authManager.currentUserID ?? "default"
        
        // Create a computed property to ensure we always have a valid statsService
        let currentStatsService: StatsService = {
            if let existingService = statsService, existingService.userID == currentUserID {
                return existingService
            } else {
                let newService = StatsService(modelContext: modelContext, userID: currentUserID)
                statsService = newService
                return newService
            }
        }()
        
        // Use user-specific query to ensure data isolation
        UserSpecificContentView(userID: currentUserID)
            .environment(currentStatsService)
            .onChange(of: currentUserID) { _, newUserID in
                statsService = StatsService(modelContext: modelContext, userID: newUserID)
            }
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
            OnboardingView(userID: userID) {
                // Completion callback - this shouldn't be called since we're using the new architecture
                print("AuthenticatedView: OnboardingView completed - this shouldn't happen in new architecture")
            }
            .environment(\.modelContext, modelContext)
        }
    }
}
