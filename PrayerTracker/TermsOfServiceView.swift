import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Terms of Service")
                            .font(.largeTitle.bold())
                        
                        Text("Effective Date: January 1, 2025")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        TermsSection(
                            title: "Acceptance of Terms",
                            content: "By downloading and using PrayerTracker, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app."
                        )
                        
                        TermsSection(
                            title: "Purpose and Use",
                            content: "PrayerTracker is designed to help Muslims track missed prayers (qaḍāʾ) and manage their prayer debt. The app is intended for personal spiritual practice and should not replace religious guidance from qualified scholars."
                        )
                        
                        TermsSection(
                            title: "Religious Guidance",
                            content: "PrayerTracker provides tools for tracking prayers but does not provide religious rulings or interpretations. Users should consult qualified Islamic scholars for religious guidance regarding missed prayers and their proper completion."
                        )
                        
                        TermsSection(
                            title: "User Responsibilities",
                            content: "You are responsible for the accuracy of the data you enter into the app. The app is a tool to assist with tracking - the actual fulfillment of missed prayers is your religious responsibility."
                        )
                        
                        TermsSection(
                            title: "Service Availability",
                            content: "We strive to keep the app available and functional, but we do not guarantee uninterrupted service. The app is designed to work offline-first to minimize dependence on internet connectivity."
                        )
                        
                        TermsSection(
                            title: "Limitations of Liability",
                            content: "PrayerTracker is provided 'as is' without warranties. We are not liable for any data loss, though we encourage users to enable iCloud sync for data backup. We are not responsible for any religious obligations or spiritual consequences."
                        )
                        
                        TermsSection(
                            title: "Intellectual Property",
                            content: "The PrayerTracker app and its content are protected by copyright and other intellectual property laws. You may not copy, modify, or distribute the app or its content without permission."
                        )
                        
                        TermsSection(
                            title: "Updates to Terms",
                            content: "We may update these terms from time to time. Significant changes will be communicated through app updates. Continued use of the app after changes constitutes acceptance of the new terms."
                        )
                        
                        TermsSection(
                            title: "Contact",
                            content: "If you have questions about these terms, please contact us through the Support option in the app settings."
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

struct TermsSection: View {
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
    TermsOfServiceView()
}
