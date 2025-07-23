import SwiftUI

struct ModernSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var showingDeleteConfirmation = false
    @State private var showingExportSheet = false
    @State private var dailyReminderEnabled = true
    @State private var reminderTime = Date()
    @State private var selectedTheme = 0 // 0: Auto, 1: Light, 2: Dark
    @State private var weeklyGoal = 35
    @State private var dailyGoal = 10
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Goals & Preferences Section
                    ModernSettingsSection(title: "Goals & Preferences", icon: "target") {
                        ModernSettingsRow(title: "Daily Prayer Goal", icon: "calendar.day.timeline.left") {
                            Picker("Daily Goal", selection: $dailyGoal) {
                                ForEach(Array(stride(from: 5, through: 30, by: 5)), id: \.self) { goal in
                                    Text("\(goal) prayers").tag(goal)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        ModernSettingsRow(title: "Weekly Goal", icon: "calendar.badge.clock") {
                            Picker("Weekly Goal", selection: $weeklyGoal) {
                                ForEach(Array(stride(from: 25, through: 50, by: 5)), id: \.self) { goal in
                                    Text("\(goal) prayers").tag(goal)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        ModernSettingsRow(title: "Theme", icon: "paintbrush") {
                            Picker("Theme", selection: $selectedTheme) {
                                Text("Auto").tag(0)
                                Text("Light").tag(1)
                                Text("Dark").tag(2)
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    
                    // Notifications Section
                    ModernSettingsSection(title: "Notifications", icon: "bell") {
                        ModernSettingsRow(title: "Daily Reminders", icon: "bell.badge") {
                            Toggle("", isOn: $dailyReminderEnabled)
                        }
                        
                        if dailyReminderEnabled {
                            ModernSettingsRow(title: "Reminder Time", icon: "clock") {
                                DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                            }
                        }
                    }
                    
                    // Data Management Section
                    ModernSettingsSection(title: "Data Management", icon: "externaldrive") {
                        ModernSettingsButton(title: "Export Data", icon: "square.and.arrow.up", action: {
                            showingExportSheet = true
                        })
                        
                        NavigationLink {
                            Text("Debt Adjustment")
                                .navigationTitle("Adjust Debt")
                        } label: {
                            ModernSettingsRowContent(title: "Manually Adjust Debt", icon: "pencil.and.outline")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // About & Support Section
                    ModernSettingsSection(title: "About & Support", icon: "info.circle") {
                        NavigationLink {
                            Text("About Qada & This App")
                                .navigationTitle("About")
                        } label: {
                            ModernSettingsRowContent(title: "About Qada & This App", icon: "book")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        ModernSettingsButton(title: "Privacy Policy", icon: "hand.raised", action: {
                            // TODO: Add privacy policy
                        })
                        
                        ModernSettingsButton(title: "Contact Support", icon: "envelope", action: {
                            // TODO: Add contact support
                        })
                    }
                    
                    // Account Section (Danger Zone)
                    ModernSettingsSection(title: "Account", icon: "person.circle") {
                        ModernSettingsButton(title: "Sign Out", icon: "rectangle.portrait.and.arrow.right", action: {
                            // TODO: Add sign out functionality
                        })
                        
                        ModernSettingsButton(title: "Delete All Data", icon: "trash", isDestructive: true, action: {
                            showingDeleteConfirmation = true
                        })
                    }
                }
                .padding(.vertical, 24)
            }
            .navigationTitle("Settings")
            .alert("Delete All Data", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    // TODO: Implement delete functionality
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete all your prayer data? This action cannot be undone.")
            }
            .sheet(isPresented: $showingExportSheet) {
                ModernExportDataView()
            }
        }
    }
}

// MARK: - Custom Settings Components

struct ModernSettingsSection<Content: View>: View {
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
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 20)
        }
    }
}

struct ModernSettingsRow<Content: View>: View {
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

struct ModernSettingsRowContent: View {
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

struct ModernSettingsButton: View {
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

// MARK: - Export Data View

struct ModernExportDataView: View {
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

#Preview {
    ModernSettingsView()
}
