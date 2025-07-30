//
//  ContentView.swift
//  PrayerTracker
//
//  Created by Developer.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AuthenticationManager.self) private var authManager
    
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
        .environment(AuthenticationManager())
}
