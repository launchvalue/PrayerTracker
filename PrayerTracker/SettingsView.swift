import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Environment(\.dismiss) private var dismiss

    @State private var showingDeleteConfirmation = false

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
                        Button("Delete All Data") {
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
            try modelContext.delete(model: UserProfile.self)
            try modelContext.delete(model: PrayerDebt.self)
            try modelContext.delete(model: DailyLog.self)
            try modelContext.save()
            print("All data deleted successfully!")
            // To restart the app to onboarding, we can dismiss all views
            // and rely on the App's initial setup to show onboarding if no profile exists.
            dismiss()
        } catch {
            print("Failed to delete all data: \(error.localizedDescription)")
        }
    }
}