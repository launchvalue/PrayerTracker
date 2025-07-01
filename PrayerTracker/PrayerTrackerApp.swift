//
//  PrayerTrackerApp.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI
import SwiftData

@main
struct PrayerTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([UserProfile.self, PrayerDebt.self, DailyLog.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("PrayerTrackerApp: ModelContainer created successfully.")
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}