
//
//  PrayerTrackerApp.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI
import SwiftData
import GoogleSignIn

@main
struct PrayerTrackerApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @State private var modelContainer: ModelContainer?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .if(let: modelContainer) { view, container in
                    view.modelContainer(container)
                }
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
            print("PrayerTrackerApp: ModelContainer created successfully for user \(userId).")
        } catch {
            print("Failed to create ModelContainer: \(error)")
        }
    }
}
