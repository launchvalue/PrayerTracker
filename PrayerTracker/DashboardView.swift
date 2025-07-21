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
    @Environment(\.modelContext) private var modelContext
    @Query private var prayerDebts: [PrayerDebt]
    
    init(profile: UserProfile) {
        self.profile = profile
        // Query for the debt associated with this user
        let userID = profile.userID
        self._prayerDebts = Query(
            filter: #Predicate<PrayerDebt> { debt in
                debt.userID == userID
            }
        )
    }
    
    var body: some View {
        if let debt = prayerDebts.first {
            HomeView(userProfile: profile, prayerDebt: debt)
        } else {
            // Create debt if it doesn't exist
            VStack {
                ProgressView()
                Text("Setting up your prayer tracker...")
                    .foregroundColor(.secondary)
            }
            .onAppear {
                createDebtIfNeeded()
            }
        }
    }
    
    private func createDebtIfNeeded() {
        // Check if debt already exists
        if prayerDebts.isEmpty {
            print("DashboardView: Creating missing PrayerDebt for user \(profile.userID)")
            let newDebt = PrayerDebt(userID: profile.userID)
            profile.debt = newDebt
            modelContext.insert(newDebt)
            
            do {
                try modelContext.save()
                print("DashboardView: Successfully created PrayerDebt for user \(profile.userID)")
            } catch {
                print("DashboardView: Failed to create PrayerDebt: \(error)")
            }
        }
    }
}
