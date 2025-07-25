
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
    @State private var authManager = AuthenticationManager()
    @State private var appState: AppState = .loading
    @State private var modelContainer: ModelContainer?
    @State private var themeManager = ThemeManager.shared
    
    // Schema definition for user-specific containers
    private let schema = Schema([
        UserProfile.self,
        PrayerDebt.self,
        DailyLog.self
    ])
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let container = modelContainer {
                    Group {
                        switch appState {
                        case .loading:
                            ProgressView("Loading...")
                                .environment(authManager)
                                
                        case .signIn:
                            SignInView()
                                .environment(authManager)
                                
                        case .onboarding(let userID):
                            OnboardingView(userID: userID) {
                                Task {
                                    await determineAppState()
                                }
                            }
                            .environment(authManager)
                                
                        case .dashboard(let userID):
                            DashboardWrapperView(userID: userID)
                                .environment(authManager)
                                
                        case .error(let error):
                            VStack {
                                Text("Error: \(error.localizedDescription)")
                                Button("Retry") {
                                    Task {
                                        await determineAppState()
                                    }
                                }
                            }
                            .environment(authManager)
                        }
                    }
                    .modelContainer(container) // User-specific container
                    .environment(themeManager)
                    .preferredColorScheme(themeManager.colorScheme)
                } else {
                    ProgressView("Initializing...")
                        .environment(authManager)
                        .environment(themeManager)
                        .preferredColorScheme(themeManager.colorScheme)
                }
            }
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
                    await createContainerForCurrentUser()
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
            .onChange(of: authManager.shouldRefreshAppState) { _, _ in
                Task {
                    await determineAppState()
                }
            }
        }
    }
    
    /// Creates a user-specific ModelContainer for the given user
    @MainActor
    private func createContainerForCurrentUser() async {
        guard let userID = authManager.currentUserID else {
            print("No userID available, creating default container")
            modelContainer = createContainer(for: "default")
            return
        }
        
        print("Creating user-specific container for user: \(userID)")
        modelContainer = createContainer(for: userID)
    }
    
    /// Creates a ModelContainer for a specific user with isolated database file
    private func createContainer(for userID: String) -> ModelContainer {
        do {
            // Create user-specific database file path
            let url = URL.applicationSupportDirectory.appending(path: "PrayerTracker_\(userID).store")
            let configuration = ModelConfiguration(schema: schema, url: url)
            let container = try ModelContainer(for: schema, configurations: [configuration])
            print("✅ Created ModelContainer for user: \(userID) with database: PrayerTracker_\(userID).store")
            return container
        } catch {
            print("❌ Failed to create ModelContainer for user \(userID): \(error)")
            print("Falling back to in-memory container for user: \(userID)")
            // Fallback to in-memory container
            do {
                let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                let container = try ModelContainer(for: schema, configurations: [configuration])
                print("✅ Created fallback in-memory container for user: \(userID)")
                return container
            } catch {
                fatalError("Failed to create fallback ModelContainer: \(error)")
            }
        }
    }
    
    @MainActor
    private func determineAppState() async {
        print("Determining app state...")
        
        // Set loading state
        appState = .loading
        
        // Create container for current user first
        await createContainerForCurrentUser()
        
        // Small delay to ensure UI updates
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        guard let userID = authManager.currentUserID else {
            print("No authenticated user, showing sign-in")
            appState = .signIn
            return
        }
        
        guard let container = modelContainer else {
            print("❌ No ModelContainer available")
            appState = .error(NSError(domain: "ModelContainer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create database container"]))
            return
        }
        
        print("Authenticated user: \(userID)")
        
        // Check if user profile exists in user-specific database
        do {
            let context = container.mainContext
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
