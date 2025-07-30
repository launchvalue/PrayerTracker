//
//  AppTabView.swift
//  PrayerTracker
//
//  Created by Developer.
//

import SwiftUI
import SwiftData
import Foundation

struct AppTabView: View {
    let profile: UserProfile
    @Environment(\.modelContext) private var modelContext
    @State private var statsService: StatsService?

    var body: some View {
        // Ensure statsService is initialized for the current user
        let currentStatsService: StatsService = {
            if let existingService = statsService, existingService.userID == profile.userID {
                return existingService
            } else {
                let newService = StatsService(modelContext: modelContext, userID: profile.userID)
                statsService = newService
                return newService
            }
        }()
        TabView {
            DashboardView(profile: profile)
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            CalendarTabView(userID: profile.userID)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            StatsView(userID: profile.userID)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }

            EducationView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }

            SettingsView(userProfile: profile, prayerDebt: profile.debt!)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .environment(currentStatsService)
    }
}

#Preview {
    AppTabView(profile: UserProfile(name: "John Doe", dailyGoal: 5, streak: 10))
}
