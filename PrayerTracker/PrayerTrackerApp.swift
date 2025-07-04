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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
        }
}