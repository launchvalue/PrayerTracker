//
//  EducationView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/29/25.
//

import SwiftUI

// MARK: - Data Model

struct EducationTopic: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let content: String
    let sources: [String: URL]
}

// MARK: - Main View

struct EducationView: View {
    @State private var searchText = ""

    private let topics: [EducationTopic] = [
        EducationTopic(
            title: "Maliki Fiqh – Missed Prayers Remain a Debt",
            subtitle: "Understanding the obligation to make up missed prayers.",
            content: "This section explains the fundamental obligation to make up missed prayers. It covers the scholarly position that all missed prayers must be repaid and includes practical advice about adding extra prayers daily.",
            sources: ["Source 1": URL(string: "https://www.google.com")!]
        ),
        EducationTopic(
            title: "Five-Prayer Sets vs. \"All Fajrs First\"",
            subtitle: "The proper sequence for making up prayers.",
            content: "This section details the proper sequence for making up prayers. It explains why the daily order (Fajr → Dhuhr → Asr → Maghrib → Isha) is preferred and covers the benefits of sequential completion.",
            sources: ["Source 1": URL(string: "https://www.google.com")!]
        ),
        EducationTopic(
            title: "Tartīb (Sequential Order) – Why Daily Bundles of 5?",
            subtitle: "The wisdom behind completing full days rather than prayer types.",
            content: "Tartīb (ترتيب) refers to the Islamic principle of maintaining proper sequence when making up missed prayers. The majority of scholars, including the Mālikī, Shāfiʿī, and Ḥanbalī schools, hold that missed prayers should be made up in their original daily order whenever reasonably possible.\n\nThe Preferred Method: Daily Bundles\nInstead of completing all Fajr prayers first, then all Dhuhr prayers, the recommended approach is:\n\nDay 1: Fajr → Dhuhr → ʿAṣr → Maghrib → ʿIshāʾ\nDay 2: Fajr → Dhuhr → ʿAṣr → Maghrib → ʿIshāʾ\nContinue this pattern...\nScholarly Evidence\nIbn Qudāmah (Ḥanbalī) states: \"If someone has multiple missed prayers, they should pray them in the order they were originally due.\"\n\nImam al-Nawawī (Shāfiʿī) explains: \"The sequence should mirror the original obligation, as this maintains the structure Allah established for daily worship.\"\n\nPractical Benefits\nClear Progress Tracking: You complete exact days rather than juggling five separate tallies\nPrevents Double-Counting: No confusion about which prayers belong to which day\nMirrors the Sunnah: Follows the natural rhythm of daily worship\nPsychological Benefit: Completing full days feels more meaningful than partial progress across prayer types\nEasier Calculation: Simple subtraction of completed days from total days owed\nWhen Tartīb Can Be Relaxed\nThe sequential order requirement is waived in cases of:\n\nExtreme hardship (mashaqqah)\nForgetfulness about the exact sequence\nVery large numbers of missed prayers where tracking becomes impractical\nTime constraints where maintaining order would prevent prayer altogether\nExample in Practice\nIf you owe 30 days of prayers:\n\n✅ Recommended: Complete Day 1 (all 5 prayers), then Day 2 (all 5 prayers), etc.\n❌ Less preferred: Complete all 30 Fajr prayers, then all 30 Dhuhr prayers, etc.\nThe daily bundle approach ensures you're following the tartīb principle while making steady, measurable progress toward clearing your prayer debt.",
            sources: ["Scholarly Source": URL(string: "https://www.google.com")!]
        ),
        EducationTopic(
            title: "Estimating Missed Prayers for Women",
            subtitle: "Guidance on calculating missed prayers considering menstrual cycles.",
            content: "This section addresses the challenge of calculating missed prayers with menstrual cycles. It explains the concept of \"preponderant likelihood\" (غلبة الظن) and provides practical guidance for estimation.",
            sources: ["Source 1": URL(string: "https://www.google.com")!]
        ),
        EducationTopic(
            title: "Frequently Asked Questions",
            subtitle: "Common questions about intention, recitation, and timing.",
            content: "This section covers common questions about intention (niyyah), explains recitation requirements (loud vs. silent), and addresses timing and sequence obligations.",
            sources: ["Source 1": URL(string: "https://www.google.com")!]
        ),
        EducationTopic(
            title: "Practical Example: Missed Isha Prayer",
            subtitle: "A step-by-step guide for a specific scenario.",
            content: "This section provides a step-by-step guide for a specific scenario. It demonstrates the proper sequence and timing and shows how to handle multiple missed prayers.",
            sources: ["Source 1": URL(string: "https://www.google.com")!]
        ),
        EducationTopic(
            title: "Technology in Service of Worship",
            subtitle: "The role of apps in spiritual practice.",
            content: "This section explains the role of apps in spiritual practice. It addresses concerns about using technology for religious obligations and emphasizes privacy and our offline-first approach.",
            sources: ["Source 1": URL(string: "https://www.google.com")!]
        )
    ]

    var filteredTopics: [EducationTopic] {
        if searchText.isEmpty {
            return topics
        } else {
            return topics.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.content.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading) {
                        Text("Learn")
                            .font(.largeTitle.bold())
                        Text("Guidance on the principles of Qada prayers.")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search Topics", text: $searchText)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    // Content Cards
                    ForEach(filteredTopics) {
                        topic in
                        EducationCardView(topic: topic)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("About Qada & This App")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Card View

struct EducationCardView: View {
    let topic: EducationTopic
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading) {
            DisclosureGroup(isExpanded: $isExpanded) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(topic.content)
                        .font(.body)
                    
                    Divider()
                    
                    Text("Sources")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    
                    ForEach(Array(topic.sources.keys), id: \.self) {
                        key in
                        if let url = topic.sources[key] {
                            Link(key, destination: url)
                                .font(.caption)
                        }
                    }
                }
            } label: {
                VStack(alignment: .leading) {
                    Text(topic.title)
                        .font(.headline.bold())
                    Text(topic.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    EducationView()
}