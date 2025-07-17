
//
//  PrayerTrackerApp.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI
import SwiftData
import GoogleSignIn

enum ModelContainerState {
    case loading
    case ready(ModelContainer)
    case error(Error)
}

@main
struct PrayerTrackerApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @State private var containerState: ModelContainerState = .loading
    
    private let schema = Schema([
        UserProfile.self,
        PrayerDebt.self,
        DailyLog.self
    ])
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch containerState {
                case .loading:
                    ProgressView("Loading...")
                        .environmentObject(authManager)
                case .ready(let container):
                    ContentView()
                        .modelContainer(container)
                        .environmentObject(authManager)
                        .id(authManager.currentUserID ?? "default")
                case .error(let error):
                    VStack {
                        Text("Error loading data")
                            .foregroundColor(.red)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("Retry") {
                            Task {
                                await createModelContainer()
                            }
                        }
                    }
                    .environmentObject(authManager)
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
            .onAppear {
                configureGoogleSignIn()
                authManager.restorePreviousSignIn()
                Task {
                    await createModelContainer()
                }
            }
            .onChange(of: authManager.currentUserID) { _, _ in
                Task {
                    await createModelContainer()
                }
            }
        }
    }
    
    private func createModelContainer() async {
        let userID = authManager.currentUserID ?? "default"
        let fileName = "\(userID).store"
        
        print("Creating ModelContainer for user: \(userID) with database: \(fileName)")
        
        // Set loading state to prevent views from accessing old model instances
        await MainActor.run {
            containerState = .loading
        }
        
        do {
            let url = URL.applicationSupportDirectory.appending(path: fileName)
            let configuration = ModelConfiguration(schema: schema, url: url)
            let container = try ModelContainer(for: schema, configurations: [configuration])
            
            // Set the new container state on main thread
            await MainActor.run {
                containerState = .ready(container)
            }
            print("Successfully created ModelContainer for user: \(userID)")
        } catch {
            print("Failed to create ModelContainer for user \(userID): \(error)")
            // Fallback to in-memory container
            do {
                let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                let container = try ModelContainer(for: schema, configurations: [configuration])
                
                await MainActor.run {
                    containerState = .ready(container)
                }
                print("Created fallback in-memory container for user: \(userID)")
            } catch {
                print("Failed to create fallback in-memory container: \(error)")
                await MainActor.run {
                    containerState = .error(error)
                }
            }
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
