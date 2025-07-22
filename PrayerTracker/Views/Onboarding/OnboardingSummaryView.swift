
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
    
    @State private var showContent = false
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
                    VStack(spacing: 0) {
                        // Header Section
                        VStack(spacing: 24) {
                            Spacer(minLength: 8)
                            
                            // Progress Indicator - All Complete!
                            HStack(spacing: 8) {
                                ForEach(0..<5) { index in
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                        .scaleEffect(showContent ? 1.2 : 0.8)
                                        .animation(.spring(response: 0.3).delay(Double(index) * 0.1), value: showContent)
                                }
                            }
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                            
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
                            .opacity(showContent ? 1.0 : 0.0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.6), value: showContent)
                            
                            Spacer(minLength: 40)
                        }
                        .frame(minHeight: geometry.size.height * 0.45)
                        
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
                                    .fill(Color.primary.opacity(0.05))
                                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                            )
                            .opacity(showContent ? 1.0 : 0.0)
                            .offset(y: showContent ? 0 : 30)
                            .animation(.easeOut(duration: 0.6).delay(0.8), value: showContent)
                            
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
                            .opacity(showContent ? 1.0 : 0.0)
                            .offset(y: showContent ? 0 : 30)
                            .animation(.easeOut(duration: 0.6).delay(1.0), value: showContent)
                            
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
                            .opacity(showContent ? 1.0 : 0.0)
                            .offset(y: showContent ? 0 : 30)
                            .animation(.easeOut(duration: 0.6).delay(1.2), value: showContent)
                            
                            // Start Journey Button
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    onSave()
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Text("Begin My Journey")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                    
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 20, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 28, style: .continuous)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: Color.green.opacity(0.3), radius: 12, x: 0, y: 4)
                            }
                            .scaleEffect(showContent ? 1.0 : 0.9)
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.4), value: showContent)
                            
                            // Navigation Buttons
                            HStack(spacing: 16) {
                                // Back button
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentStep -= 1
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 16, weight: .semibold))
                                        Text("Back")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.accentColor)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                                            .fill(Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 25, style: .continuous)
                                                    .stroke(Color.accentColor, lineWidth: 2)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Finish button
                                Button(action: {
                                    onSave()
                                }) {
                                    HStack(spacing: 8) {
                                        Text("Finish")
                                            .font(.system(size: 16, weight: .semibold))
                                        
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.top, 32)
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.6).delay(1.0), value: showContent)
                            
                            // Bottom spacing
                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .onAppear {
            showContent = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showCelebration = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                animateStats = true
            }
        }
    }
    
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
