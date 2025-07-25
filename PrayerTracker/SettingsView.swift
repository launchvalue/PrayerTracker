import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AuthenticationManager.self) private var authManager

    @State private var showingDeleteConfirmation = false
    @State private var showingExportSheet = false
    @State private var dailyReminderEnabled = true
    @State private var reminderTime = Date()
    @State private var selectedTheme = 0 // 0: Auto, 1: Light, 2: Dark
    @State private var isDeleting = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    @State private var showingAbout = false
    
    let userProfile: UserProfile
    let prayerDebt: PrayerDebt
    
    init(userProfile: UserProfile, prayerDebt: PrayerDebt) {
        self.userProfile = userProfile
        self.prayerDebt = prayerDebt
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Standard Header
                    Text("Settings")
                        .font(.largeTitle.bold())
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                    
                    // Goals & Preferences Section
                    SettingsSection(title: "Goals & Preferences", icon: "target") {
                        SettingsRow(title: "Daily Prayer Goal", icon: "calendar.day.timeline.left") {
                            Picker("Daily Goal", selection: Binding(
                                get: { userProfile.dailyGoal },
                                set: { newValue in
                                    userProfile.dailyGoal = newValue
                                    try? modelContext.save()
                                }
                            )) {
                                ForEach(Array(stride(from: 5, through: 30, by: 5)), id: \.self) { goal in
                                    Text("\(goal) prayers").tag(goal)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        SettingsRow(title: "Theme", icon: "paintbrush") {
                            Picker("Theme", selection: $selectedTheme) {
                                Text("Auto").tag(0)
                                Text("Light").tag(1)
                                Text("Dark").tag(2)
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    
                    // Notifications Section
                    SettingsSection(title: "Notifications", icon: "bell") {
                        SettingsRow(title: "Daily Reminders", icon: "bell.badge") {
                            Toggle("", isOn: $dailyReminderEnabled)
                        }
                        
                        if dailyReminderEnabled {
                            SettingsRow(title: "Reminder Time", icon: "clock") {
                                DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                            }
                        }
                    }
                    
                    // Data Management Section
                    SettingsSection(title: "Data Management", icon: "externaldrive") {
                        SettingsButton(title: "Export Data", icon: "square.and.arrow.up", action: {
                            showingExportSheet = true
                        })
                        
                        NavigationLink {
                            DebtAdjustmentView(prayerDebt: prayerDebt)
                        } label: {
                            SettingsRowContent(title: "Manually Adjust Debt", icon: "pencil.and.outline")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // About & Support Section
                    SettingsSection(title: "About & Support", icon: "info.circle") {
                        SettingsButton(title: "About Qada & This App", icon: "book", action: {
                            showingAbout = true
                        })
                        .buttonStyle(PlainButtonStyle())
                        
                        SettingsButton(title: "Privacy Policy", icon: "hand.raised", action: {
                            showingPrivacyPolicy = true
                        })
                        
                        SettingsButton(title: "Terms of Service", icon: "doc.text", action: {
                            showingTermsOfService = true
                        })
                        
                        SettingsButton(title: "Contact Support", icon: "envelope", action: {
                            // TODO: Add contact support
                        })
                    }
                    
                    // Account Section (Danger Zone)
                    SettingsSection(title: "Account", icon: "person.circle") {
                        SettingsButton(title: "Sign Out", icon: "rectangle.portrait.and.arrow.right", action: {
                            authManager.signOut()
                        })
                        
                        SettingsButton(title: "Delete All Data", icon: "trash", isDestructive: true, action: {
                            showingDeleteConfirmation = true
                        })
                    }
                }
                .padding(.vertical, 24)
            }
.alert("Delete All Data", isPresented: $showingDeleteConfirmation) {
                Button(isDeleting ? "Deleting..." : "Delete", role: .destructive) {
                    deleteAllData()
                }
                .disabled(isDeleting)
                Button("Cancel", role: .cancel) { }
                    .disabled(isDeleting)
            } message: {
                Text(isDeleting ? "Deleting all your prayer data..." : "Are you sure you want to delete all your prayer data? This action cannot be undone and will remove iCloud backups too.")
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportDataView(userProfile: userProfile)
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showingTermsOfService) {
                TermsOfServiceView()
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .overlay {
                if isDeleting {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Deleting all data...")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding(32)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
        }
    }

    private func deleteAllData() {
        isDeleting = true
        
        Task {
            do {
                let userID = userProfile.userID
                print("Starting data deletion for user: \(userID)")
                
                // Delete all DailyLog entries for this user
                let dailyLogPredicate = #Predicate<DailyLog> { log in
                    log.userID == userID
                }
                let dailyLogDescriptor = FetchDescriptor<DailyLog>(predicate: dailyLogPredicate)
                let dailyLogs = try modelContext.fetch(dailyLogDescriptor)
                
                for log in dailyLogs {
                    modelContext.delete(log)
                }
                print("Deleted \(dailyLogs.count) daily log entries")
                
                // Delete current user's profile and debt
                modelContext.delete(userProfile)
                modelContext.delete(prayerDebt)
                
                try modelContext.save()
                print("All data deleted successfully for user: \(userID)")
                
                // Trigger app state refresh to show onboarding
                await MainActor.run {
                    authManager.triggerAppStateRefresh()
                    dismiss()
                }
                
            } catch {
                print("Failed to delete user data: \(error.localizedDescription)")
                await MainActor.run {
                    isDeleting = false
                }
            }
        }
    }
}

// MARK: - Custom Settings Components

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            // Section Header
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.accentColor)
                    .frame(width: 24)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            
            // Section Content
            VStack(spacing: 0) {
                content
            }
            .standardCardBackground()
            .padding(.horizontal, 20)
        }
    }
}

struct SettingsRow<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            content
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
        )
    }
}

struct SettingsRowContent: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

struct SettingsButton: View {
    let title: String
    let icon: String
    let isDestructive: Bool
    let action: () -> Void
    
    init(title: String, icon: String, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isDestructive ? .red : .secondary)
                    .frame(width: 20)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(isDestructive ? .red : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Export Data View (Placeholder)

struct ExportDataView: View {
    let userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                
                Text("Export Your Data")
                    .font(.headline)
                
                Text("Export your prayer tracking data to backup or transfer to another device.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 12) {
                    Button("Export as JSON") {
                        // TODO: Implement JSON export
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Export as CSV") {
                        // TODO: Implement CSV export
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(20)
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}