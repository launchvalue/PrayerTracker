//
//  AppTabView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI

struct AppTabView: View {
    let profile: UserProfile

    var body: some View {
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

            SettingsView(userID: profile.userID)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    AppTabView(profile: UserProfile(name: "John Doe", dailyGoal: 5, streak: 10))
}
