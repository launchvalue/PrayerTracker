//
//  AboutView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 7/24/25.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About Qada & This App")
                            .font(.largeTitle.bold())
                        
                        Text("Understanding missed prayers and how PrayerTracker helps you fulfill your obligations")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    
                    // What is Qada Section
                    VStack(alignment: .leading, spacing: 16) {
                        AboutSection(
                            title: "What is Qaḍāʾ (قضاء)?",
                            icon: "book.closed",
                            content: """
                            Qaḍāʾ refers to the Islamic obligation to make up missed prayers. In Islamic jurisprudence, every obligatory prayer remains a debt until it is performed, regardless of how much time has passed.
                            
                            According to Maliki fiqh, missed prayers accumulate as a spiritual debt that must be fulfilled. This principle recognizes that life circumstances sometimes prevent us from praying at the prescribed times, but the obligation remains.
                            """
                        )
                        
                        AboutSection(
                            title: "Why Make Up Missed Prayers?",
                            icon: "heart",
                            content: """
                            Prayer is one of the five pillars of Islam and a direct connection between the believer and Allah. When we miss prayers due to sleep, forgetfulness, or other circumstances, we haven't lost the opportunity to fulfill this obligation.
                            
                            Making up missed prayers demonstrates our commitment to maintaining this spiritual connection and acknowledging that our duties to Allah remain constant, even when we fall short.
                            """
                        )
                        
                        AboutSection(
                            title: "The Challenge of Tracking",
                            icon: "exclamationmark.triangle",
                            content: """
                            Many Muslims struggle with tracking their missed prayers over months or years. Traditional methods like paper logs can be lost, and mental estimates are often inaccurate.
                            
                            This creates a barrier to fulfilling our obligations—not knowing exactly how many prayers we owe can lead to procrastination or giving up entirely.
                            """
                        )
                    }
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // How PrayerTracker Helps
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "iphone")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                Text("How PrayerTracker Helps")
                                    .font(.title2.bold())
                                    .foregroundColor(.primary)
                            }
                            
                            Text("Technology in service of worship")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        
                        AboutSection(
                            title: "Accurate Tracking",
                            icon: "chart.bar",
                            content: """
                            PrayerTracker provides precise counting of your missed prayers, eliminating guesswork. Whether you missed a few prayers or need to calculate years of debt, the app handles the mathematics for you.
                            
                            You can input your debt through multiple methods: date ranges, bulk amounts, or individual prayer counts—whatever works best for your situation.
                            """
                        )
                        
                        AboutSection(
                            title: "Goal Setting & Motivation",
                            icon: "target",
                            content: """
                            Set realistic daily goals for making up prayers. The app tracks your progress, celebrates your achievements, and helps you build consistent habits.
                            
                            By breaking down large numbers into manageable daily targets, what once seemed overwhelming becomes achievable through steady, consistent effort.
                            """
                        )
                        
                        AboutSection(
                            title: "Privacy & Security",
                            icon: "lock.shield",
                            content: """
                            Your prayer data is deeply personal. PrayerTracker stores all information locally on your device with optional iCloud sync to your private account.
                            
                            We never access, collect, or share your prayer data. Your spiritual journey remains between you and Allah.
                            """
                        )
                        
                        AboutSection(
                            title: "Educational Resources",
                            icon: "graduationcap",
                            content: """
                            Access scholarly guidance about missed prayers, including Maliki fiqh principles, proper sequencing (tartīb), and practical examples.
                            
                            Learn from authentic Islamic sources while using the app as a practical tool to implement these teachings.
                            """
                        )
                    }
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // Our Mission
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "heart.text.square")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                Text("Our Mission")
                                    .font(.title2.bold())
                                    .foregroundColor(.primary)
                            }
                            
                            Text("Removing barriers to spiritual fulfillment")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("""
                            PrayerTracker was created to remove the practical barriers that prevent Muslims from fulfilling their prayer obligations. We believe that technology should serve worship, not complicate it.
                            
                            By automating the tracking and providing gentle motivation, the app frees you to focus on what matters most: your connection with Allah through prayer.
                            
                            Whether you have a few missed prayers or years of debt, this app is designed to help you take that first step and maintain consistent progress toward spiritual fulfillment.
                            """)
                                .font(.body)
                                .foregroundColor(.primary)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Important Note
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .font(.title3)
                                    .foregroundColor(.orange)
                                Text("Important Note")
                                    .font(.headline.bold())
                                    .foregroundColor(.primary)
                            }
                            
                            Text("""
                            PrayerTracker is a tool to assist with tracking prayers. For religious guidance regarding missed prayers, their proper completion, and specific rulings, please consult qualified Islamic scholars.
                            
                            The app provides educational content from authentic sources but does not replace scholarly guidance for your individual circumstances.
                            """)
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.1))
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 32)
                }
                .padding(.vertical, 20)
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

// MARK: - About Section Component

struct AboutSection: View {
    let title: String
    let icon: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.accentColor)
                    .frame(width: 24)
                
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(.primary)
            }
            
            Text(content)
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    AboutView()
}
