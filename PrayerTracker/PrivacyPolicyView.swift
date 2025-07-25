import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Privacy Policy")
                            .font(.largeTitle.bold())
                        
                        Text("Effective Date: January 1, 2025")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        PolicySection(
                            title: "Data Collection",
                            content: "PrayerTracker collects minimal data necessary to function. We only store your prayer debt counts, daily goals, and prayer completion logs. All data is stored locally on your device and, if enabled, synced privately through Apple's CloudKit to your personal iCloud account."
                        )
                        
                        PolicySection(
                            title: "Data Storage",
                            content: "Your data is stored locally on your device using SwiftData. If you enable iCloud sync, your data is securely synchronized to your private CloudKit database. We do not have access to your CloudKit data - it remains under your Apple ID's control."
                        )
                        
                        PolicySection(
                            title: "Data Sharing",
                            content: "We do not share, sell, or distribute your personal prayer data with any third parties. Your spiritual practice data remains private and is only accessible to you."
                        )
                        
                        PolicySection(
                            title: "Analytics",
                            content: "We do not collect usage analytics, tracking data, or any personal information for marketing purposes. The app functions entirely offline-first with optional iCloud sync."
                        )
                        
                        PolicySection(
                            title: "Authentication",
                            content: "We use Google Sign-In and Apple Sign-In only for user identification and data isolation. We do not access your Google or Apple account data beyond the basic user identifier needed to keep your prayer data separate from other users."
                        )
                        
                        PolicySection(
                            title: "Data Deletion",
                            content: "You can delete all your data at any time from the Settings page. This will permanently remove all prayer debt records, daily logs, and user profile information from both local storage and iCloud (if sync is enabled)."
                        )
                        
                        PolicySection(
                            title: "Contact",
                            content: "If you have questions about this privacy policy or your data, please contact us through the Support option in the app settings."
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
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

struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    PrivacyPolicyView()
}
