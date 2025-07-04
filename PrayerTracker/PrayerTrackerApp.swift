
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
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([UserProfile.self, PrayerDebt.self, DailyLog.self])
            let modelConfiguration = ModelConfiguration(schema: schema, url: URL.applicationSupportDirectory.appending(path: "defaultUser.store"))
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .modelContainer(modelContainer)
        }
    }
}
