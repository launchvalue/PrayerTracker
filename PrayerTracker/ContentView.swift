//
//  ContentView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI
import SwiftData
import GoogleSignIn

struct ContentView: View {
    @EnvironmentObject private var authManager: AuthenticationManager

    private var currentUserID: String? {
        GIDSignIn.sharedInstance.currentUser?.userID
    }

    var body: some View {
        Group {
            if authManager.isSignedIn {
                AuthenticatedView()
                    .id(currentUserID)
            } else {
                SignInView()
                    .environmentObject(authManager)
            }
        }
    }
}

#Preview {
    ContentView()
}
