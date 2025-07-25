
//
//  OnboardingSummaryView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI

struct OnboardingSummaryView: View {
    let name: String
    let gender: String
    let calculationMethod: CalculationMethod
    let startDate: Date
    let endDate: Date
    let bulkYears: Int
    let bulkMonths: Int
    let bulkDays: Int
    let customFajr: Int
    let customDhuhr: Int
    let customAsr: Int
    let customMaghrib: Int
    let customIsha: Int
    let dailyGoal: Int
    let averageCycleLength: Int
    @Binding var currentStep: Int
    let onSave: () -> Void
    
    @State private var showDots = false
    @State private var showCelebration = false
    @State private var animateStats = false

    private var totalDebt: Int {
        switch calculationMethod {
        case .dateRange:
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: startDate, to: endDate)
            var totalDays = (components.day ?? 0) + 1
            
            if gender == "Female" && averageCycleLength > 0 {
                let approximateMonths = Double(totalDays) / 30.44
                let totalMenstrualDays = Int(approximateMonths * Double(averageCycleLength))
                totalDays = max(0, totalDays - totalMenstrualDays)
            }
            return totalDays * 5
        case .bulk:
            return (bulkYears * 354 * 5) + (bulkMonths * 30 * 5) + (bulkDays * 5)
        case .custom:
            return customFajr + customDhuhr + customAsr + customMaghrib + customIsha
        }
    }

    private var estimatedCompletionDate: String {
        guard dailyGoal > 0 else { return "N/A" }
        let daysToCompletion = Double(totalDebt) / Double(dailyGoal)
        let completionDate = Calendar.current.date(byAdding: .day, value: Int(ceil(daysToCompletion)), to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: completionDate)
    }
    
    private var estimatedDays: Int {
        guard dailyGoal > 0 else { return 0 }
        return Int(ceil(Double(totalDebt) / Double(dailyGoal)))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.accentColor.opacity(0.1),
                        Color.clear,
                        Color.green.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        VStack(spacing: 16) {
                            Spacer(minLength: 8)
                            
                            // Progress Indicator - All Complete!
                            HStack(spacing: 8) {
                                ForEach(0..<5) { index in
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                        .scaleEffect(showDots ? 1.2 : 0.8)
                                        .animation(.spring(response: 0.3).delay(Double(index) * 0.1), value: showDots)
                                }
                            }
                            .modifier(FadeInOnAppearModifier(delay: 0.2, duration: 0.5))
                            .padding(.bottom, 16)
                            
                            // Celebration Icon
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [Color.green.opacity(0.2), Color.green.opacity(0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 100, height: 100)
                                    .scaleEffect(showCelebration ? 1.0 : 0.5)
                                    .opacity(showCelebration ? 1.0 : 0.0)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 50, weight: .medium))
                                    .foregroundColor(.green)
                                    .scaleEffect(showCelebration ? 1.0 : 0.5)
                                    .opacity(showCelebration ? 1.0 : 0.0)
                            }
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: showCelebration)
                            
                            // Title Section
                            VStack(spacing: 12) {
                                Text("You're All Set, \(name)!")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                
                                Text("Your spiritual journey begins now")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .modifier(FadeInOnAppearModifier(delay: 0.6, duration: 0.6))
                        }
                        .frame(minHeight: geometry.size.height * 0.20)
                        
                        // Summary Section
                        VStack(spacing: 24) {
                            // Journey Overview Card
                            VStack(spacing: 20) {
                                Text("Your Journey Overview")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                // Stats Grid
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 16) {
                                    StatCard(
                                        title: "Total Prayers",
                                        value: "\(totalDebt)",
                                        subtitle: "to complete",
                                        icon: "list.number",
                                        color: .blue,
                                        animate: animateStats
                                    )
                                    
                                    StatCard(
                                        title: "Daily Goal",
                                        value: "\(dailyGoal)",
                                        subtitle: "prayers/day",
                                        icon: "target",
                                        color: .orange,
                                        animate: animateStats
                                    )
                                    
                                    StatCard(
                                        title: "Estimated Time",
                                        value: "\(estimatedDays)",
                                        subtitle: "days",
                                        icon: "calendar",
                                        color: .green,
                                        animate: animateStats
                                    )
                                    
                                    StatCard(
                                        title: "Completion",
                                        value: estimatedCompletionDate.prefix(6).description,
                                        subtitle: "target date",
                                        icon: "flag.checkered",
                                        color: .purple,
                                        animate: animateStats
                                    )
                                }
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(.background)
                                    .shadow(color: Color.primary.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            .modifier(FadeInOnAppearModifier(delay: 0.8, duration: 0.6))
                            
                            // Method Summary Card
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: methodIcon)
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.accentColor)
                                    
                                    Text("Calculation Method")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                
                                VStack(spacing: 8) {
                                    HStack {
                                        Text(calculationMethod.rawValue)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                    }
                                    
                                    if !methodDetails.isEmpty {
                                        HStack {
                                            Text(methodDetails)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                            
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.primary.opacity(0.05))
                            )
                            .modifier(FadeInOnAppearModifier(delay: 1.0, duration: 0.6))
                            
                            // Motivational Message
                            VStack(spacing: 16) {
                                Text("🌟 Remember")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                VStack(spacing: 12) {
                                    MotivationalRow(icon: "heart.fill", text: "Every prayer brings you closer to Allah", color: .red)
                                    MotivationalRow(icon: "leaf.fill", text: "Consistency matters more than perfection", color: .green)
                                    MotivationalRow(icon: "star.fill", text: "Your spiritual growth is a beautiful journey", color: .yellow)
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.accentColor.opacity(0.05))
                            )
                            .modifier(FadeInOnAppearModifier(delay: 1.2, duration: 0.6))
                            

                            // Navigation Buttons
                            SimpleNavigationButtons(
                                backAction: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentStep -= 1
                                    }
                                },
                                continueAction: {
                                    // This is the final step, so continue completes onboarding
                                    onSave()
                                },
                                continueText: "Begin Your Journey",
                                canGoBack: true,
                                canContinue: true
                            )
                            .padding(.top, 32)
                            .modifier(FadeInOnAppearModifier(delay: 1.0, duration: 0.6))
                            
                            // Bottom spacing
                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 32)
                }
                .scrollIndicators(.hidden)
            }
        }
        .onAppear {
            showDots = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showCelebration = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                animateStats = true
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var methodIcon: String {
        switch calculationMethod {
        case .dateRange:
            return "calendar.badge.clock"
        case .bulk:
            return "clock.badge.questionmark"
        case .custom:
            return "slider.horizontal.3"
        }
    }
    
    private var methodDetails: String {
        switch calculationMethod {
        case .dateRange:
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        case .bulk:
            var parts: [String] = []
            if bulkYears > 0 { parts.append("\(bulkYears)y") }
            if bulkMonths > 0 { parts.append("\(bulkMonths)m") }
            if bulkDays > 0 { parts.append("\(bulkDays)d") }
            return parts.joined(separator: " ")
        case .custom:
            return "Custom prayer counts entered"
        }
    }
}

// MARK: - Supporting Components

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let animate: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
                .scaleEffect(animate ? 1.0 : 0.5)
                .opacity(animate ? 1.0 : 0.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1), value: animate)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .scaleEffect(animate ? 1.0 : 0.8)
                    .opacity(animate ? 1.0 : 0.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.2), value: animate)
                
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color.opacity(0.1))
        )
    }
}

struct MotivationalRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(2)
            
            Spacer()
        }
    }
}
