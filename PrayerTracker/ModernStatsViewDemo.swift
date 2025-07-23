//
//  ModernStatsViewDemo.swift
//  PrayerTracker
//
//  Modernized StatsView demonstrating iOS 18+ Style Guide implementation
//

import SwiftUI

struct ModernStatsViewDemo: View {
    @State private var showContent = false
    let userID: String

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section - Following style guide patterns (25% of screen height)
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            Spacer(minLength: DesignSystem.Spacing.sm)
                            
                            // Modern header with consistent typography
                            VStack(spacing: DesignSystem.Spacing.sm) {
                                Text("Prayer Statistics")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                
                                Text("Track your spiritual progress")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .opacity(showContent ? 1.0 : 0.0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
                            
                            Spacer(minLength: DesignSystem.Spacing.lg)
                        }
                        .frame(minHeight: geometry.size.height * 0.25)
                        
                        // Content Section - Demo cards
                        demoContent
                        
                        Spacer(minLength: DesignSystem.Spacing.xl)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .background(
                // Modern gradient background following style guide
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.accentColor.opacity(0.1),
                        Color.clear,
                        Color.accentColor.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                showContent = true
            }
        }
    }
    
    // MARK: - Demo Content
    private var demoContent: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Overall Progress Card
            overallProgressCard
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
            
            // Prayer Breakdown Card
            prayerBreakdownCard
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
            
            // Weekly Goal Card
            weeklyGoalCard
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
        }
        .adaptiveHorizontalPadding()
    }
    
    // MARK: - Card Components
    private var overallProgressCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "chart.pie")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.accentColor)
                
                Text("Overall Progress")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text("Total Completed")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("127")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Remaining Debt")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("43")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.red)
                }
                
                // Progress bar
                ProgressView(value: 0.75)
                    .tint(.accentColor)
                    .scaleEffect(y: 2.0)
            }
        }
        .padding(DesignSystem.Spacing.contentMargin)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var prayerBreakdownCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "chart.bar")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.accentColor)
                
                Text("Prayer Breakdown")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: DesignSystem.Spacing.md) {
                ForEach(["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"], id: \.self) { prayerType in
                    HStack {
                        Circle()
                            .fill(prayerTypeColor(for: prayerType))
                            .frame(width: 12, height: 12)
                        
                        Text(prayerType)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(Int.random(in: 15...30))")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("\(Int.random(in: 5...15)) left")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.contentMargin)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var weeklyGoalCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "target")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.accentColor)
                
                Text("Weekly Goal")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text("This Week")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("18/25")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                ProgressView(value: 0.72)
                    .tint(.green)
                    .scaleEffect(y: 2.0)
                
                HStack {
                    Text("Current Streak")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("12 days")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(DesignSystem.Spacing.contentMargin)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Helper Functions
    private func prayerTypeColor(for prayerType: String) -> Color {
        switch prayerType {
        case "Fajr": return .blue
        case "Dhuhr": return .orange
        case "Asr": return .yellow
        case "Maghrib": return .pink
        case "Isha": return .purple
        default: return .gray
        }
    }
}

#Preview {
    ModernStatsViewDemo(userID: "preview-user")
}
