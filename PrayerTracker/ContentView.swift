//
//  ContentView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI
import SwiftData

import SwiftUI
import SwiftData
import CloudKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var iCloudAccountStatus: CKAccountStatus = .couldNotDetermine
    @State private var showOnboarding: Bool = true
    

    var body: some View {
        Group {
            if iCloudAccountStatus == .available {
                if let profile = profiles.first {
                    AppTabView(profile: profile)
                        .environment(StatsService(modelContext: modelContext))
                } else {
                    OnboardingView()
                }
            } else {
                iCloudSignInView(iCloudAccountStatus: iCloudAccountStatus)
            }
        }
        .task {
            print("ContentView: Initializing. Current profiles count: \(profiles.count)")
            await checkICloudAccountStatus()
            if profiles.first != nil {
                print("ContentView: Profile exists on task load.")
            }
        }
        .onChange(of: profiles.first) {
            // This will trigger when a profile is saved/loaded
            if profiles.first != nil {
                showOnboarding = false
                print("ContentView: Profile detected, setting showOnboarding to false. Profile: \(profiles.first!)")
            } else {
                print("ContentView: No profile detected in onChange.")
            }
        }
        .onChange(of: showOnboarding) {
            print("ContentView: showOnboarding changed to \(showOnboarding)")
        }
    }

    private func checkICloudAccountStatus() async {
        do {
            let status = try await CKContainer.default().accountStatus()
            DispatchQueue.main.async {
                self.iCloudAccountStatus = status
                print("iCloud Account Status: \(status.rawValue)")
            }
        } catch {
            DispatchQueue.main.async {
                self.iCloudAccountStatus = .couldNotDetermine
                print("Error checking iCloud account status: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}
