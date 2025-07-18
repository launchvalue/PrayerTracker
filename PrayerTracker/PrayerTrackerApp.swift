
//
//  PrayerTrackerApp.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI
import SwiftData
import GoogleSignIn

enum AppState {
    case loading
    case signIn
    case onboarding(userID: String)
    case dashboard(userID: String)
    case error(Error)
}

@main
struct PrayerTrackerApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @State private var appState: AppState = .loading
    
    // Single ModelContainer for the entire app lifecycle - no switching!
    private let modelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            PrayerDebt.self,
            DailyLog.self
        ])
        
        do {
            // Use a single database file for all users
            let url = URL.applicationSupportDirectory.appending(path: "PrayerTracker.store")
            let configuration = ModelConfiguration(schema: schema, url: url)
            let container = try ModelContainer(for: schema, configurations: [configuration])
            print("Created single ModelContainer with database: PrayerTracker.store")
            return container
        } catch {
            print("Failed to create ModelContainer: \(error)")
            // Fallback to in-memory container
            do {
                let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                let container = try ModelContainer(for: schema, configurations: [configuration])
                print("Created fallback in-memory container")
                return container
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appState {
                case .loading:
                    ProgressView("Loading...")
                        .environmentObject(authManager)
                        
                case .signIn:
                    SignInView()
                        .environmentObject(authManager)
                        
                case .onboarding(let userID):
                    OnboardingView(userID: userID) {
                        Task {
                            await determineAppState()
                        }
                    }
                    .environmentObject(authManager)
                        
                case .dashboard(let userID):
                    DashboardWrapperView(userID: userID)
                        .environmentObject(authManager)
                        
                case .error(let error):
                    VStack {
                        Text("Error loading app")
                            .foregroundColor(.red)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("Retry") {
                            Task {
                                await determineAppState()
                            }
                        }
                    }
                    .environmentObject(authManager)
                }
            }
            .modelContainer(modelContainer) // Single container for entire app
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
            .onAppear {
                configureGoogleSignIn()
                authManager.restorePreviousSignIn {
                    Task {
                        await determineAppState()
                    }
                }
            }
            .onChange(of: authManager.currentUserID) { _, _ in
                Task {
                    await determineAppState()
                }
            }
            .onChange(of: authManager.isAuthenticationComplete) { _, isComplete in
                if isComplete {
                    Task {
                        await determineAppState()
                    }
                }
            }
        }
    }
    
    @MainActor
    private func determineAppState() async {
        print("Determining app state...")
        
        // Set loading state
        appState = .loading
        
        // Small delay to ensure UI updates
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        guard let userID = authManager.currentUserID else {
            print("No authenticated user, showing sign-in")
            appState = .signIn
            return
        }
        
        print("Authenticated user: \(userID)")
        
        // Check if user profile exists in database
        do {
            let context = modelContainer.mainContext
            let predicate = #Predicate<UserProfile> { profile in
                profile.userID == userID
            }
            let descriptor = FetchDescriptor<UserProfile>(predicate: predicate)
            let profiles = try context.fetch(descriptor)
            
            if profiles.isEmpty {
                print("New user, showing onboarding")
                appState = .onboarding(userID: userID)
            } else {
                print("Returning user, showing dashboard")
                appState = .dashboard(userID: userID)
            }
        } catch {
            print("Error checking user profile: \(error)")
            appState = .error(error)
        }
    }
    
    private func configureGoogleSignIn() {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            print("GoogleService-Info.plist not found")
            return
        }
        
        guard let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
            print("CLIENT_ID not found in GoogleService-Info.plist")
            return
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
    }
}
