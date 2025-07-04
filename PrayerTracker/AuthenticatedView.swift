
import SwiftUI
import SwiftData
import GoogleSignIn

struct AuthenticatedView: View {
    @State private var modelContainer: ModelContainer?
    
    var body: some View {
        if let modelContainer = modelContainer {
            MainAppView()
                .modelContainer(modelContainer)
        } else {
            ProgressView()
                .onAppear(perform: setupModelContainer)
        }
    }
    
    private func setupModelContainer() {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            return
        }
        let userId = user.userID ?? "defaultUser"
        let containerURL = URL.applicationSupportDirectory.appending(path: "\(userId).store")
        let schema = Schema([UserProfile.self, PrayerDebt.self, DailyLog.self])
        let modelConfiguration = ModelConfiguration(schema: schema, url: containerURL)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("AuthenticatedView: ModelContainer created successfully for user \(userId).")
        } catch {
            print("Failed to create ModelContainer: \(error)")
        }
    }
}

struct MainAppView: View {
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
