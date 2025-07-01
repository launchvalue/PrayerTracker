//
//  DashboardView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    let profile: UserProfile
    
    var body: some View {
        if let debt = profile.debt {
            HomeView(userProfile: profile, prayerDebt: .constant(debt))
        } else {
            Text("No debt profile found.")
        }
    }
}
