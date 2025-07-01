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

            CalendarTabView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            StatsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }

            EducationView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
        }
    }
}

#Preview {
    AppTabView(profile: UserProfile(name: "John Doe", dailyGoal: 5, streak: 10))
}
