//
//  ContentView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        if authManager.isSignedIn {
            AuthenticatedView()
        } else {
            SignInView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
}
