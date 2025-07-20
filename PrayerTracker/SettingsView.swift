import SwiftUI
import SwiftData
import GoogleSignIn

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthenticationManager.self) private var authManager
    @Query private var userProfiles: [UserProfile]
    @Environment(\.dismiss) private var dismiss

    @State private var showingDeleteConfirmation = false
    
    let userID: String
    
    init(userID: String) {
        self.userID = userID
        
        // Filter UserProfile by userID for data isolation
        self._userProfiles = Query(
            filter: #Predicate<UserProfile> { profile in
                profile.userID == userID
            }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                if let profile = userProfiles.first {
                    Section(header: Text("Your Goal")) {
                        Picker("Daily Prayer Goal", selection: Binding(
                            get: { profile.dailyGoal },
                            set: { newValue in
                                profile.dailyGoal = newValue
                                try? modelContext.save()
                            }
                        )) {
                            ForEach(Array(stride(from: 5, through: 30, by: 5)), id: \.self) { goal in
                                Text("\(goal) prayers per day").tag(goal)
                            }
                        }
                    }

                    Section(header: Text("Corrections")) {
                        NavigationLink("Manually Adjust Debt") {
                            if let debt = profile.debt {
                                DebtAdjustmentView(prayerDebt: debt)
                            } else {
                                Text("No prayer debt data found.")
                            }
                        }
                    }

                    Section(header: Text("About")) {
                        NavigationLink("About Qada & This App") {
                            EducationView()
                        }
                    }

                    Section(header: Text("Danger Zone")) {
                        Button("Sign Out", action: {
                            authManager.signOut()
                        })
                        Button("Delete All Data", role: .destructive) {
                            showingDeleteConfirmation = true
                        }
                    }
                } else {
                    Text("No user profile found. Please complete onboarding.")
                }
            }
            .navigationTitle("Settings")
            .alert("Delete All Data", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteAllData()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete all your prayer data? This action cannot be undone and will remove iCloud backups too.")
            }
        }
    }

    private func deleteAllData() {
        do {
            // Delete only current user's data by filtering with userID
            let userProfileDescriptor = FetchDescriptor<UserProfile>(
                predicate: #Predicate<UserProfile> { profile in
                    profile.userID == userID
                }
            )
            let userProfiles = try modelContext.fetch(userProfileDescriptor)
            for profile in userProfiles {
                modelContext.delete(profile)
            }
            
            let prayerDebtDescriptor = FetchDescriptor<PrayerDebt>(
                predicate: #Predicate<PrayerDebt> { debt in
                    debt.userID == userID
                }
            )
            let prayerDebts = try modelContext.fetch(prayerDebtDescriptor)
            for debt in prayerDebts {
                modelContext.delete(debt)
            }
            
            let dailyLogDescriptor = FetchDescriptor<DailyLog>(
                predicate: #Predicate<DailyLog> { log in
                    log.userID == userID
                }
            )
            let dailyLogs = try modelContext.fetch(dailyLogDescriptor)
            for log in dailyLogs {
                modelContext.delete(log)
            }
            
            try modelContext.save()
            print("All data deleted successfully for user: \(userID)")
            
            // Trigger app state refresh to show onboarding for the now "new" user
            authManager.triggerAppStateRefresh()
            
            // Dismiss settings view
            dismiss()
        } catch {
            print("Failed to delete user data: \(error.localizedDescription)")
        }
    }
}