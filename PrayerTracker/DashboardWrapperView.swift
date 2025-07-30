//
//  DashboardWrapperView.swift
//  PrayerTracker
//
//  Created by Developer.
//

import SwiftUI
import SwiftData

struct DashboardWrapperView: View {
    let userID: String
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext
    
    init(userID: String) {
        self.userID = userID
        self._profiles = Query(
            filter: #Predicate<UserProfile> { profile in
                profile.userID == userID
            }
        )
    }
    
    var body: some View {
        if let profile = profiles.first {
            AppTabView(profile: profile)
        } else {
            // This shouldn't happen if the app state logic is correct
            // but we'll show a loading state just in case
            VStack {
                ProgressView()
                Text("Loading profile...")
                    .foregroundColor(.secondary)
            }
            .onAppear {
                print("Warning: DashboardWrapperView couldn't find profile for userID: \(userID)")
            }
        }
    }
}

#Preview {
    DashboardWrapperView(userID: "preview-user-id")
        .modelContainer(for: [UserProfile.self, PrayerDebt.self, DailyLog.self])
}
