import SwiftUI

struct GoalSelectionView: View {
    @Binding var dailyGoal: Int
    @Binding var currentStep: Int
    
    // Debt calculation parameters
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
    let averageCycleLength: Int

    @State private var selectedGoalIndex = 0
    
    private let goalOptions = Array(stride(from: 5, through: 30, by: 5))
    
    // Goal recommendations based on different scenarios
    private let goalRecommendations = [
        (range: 5...10, title: "Gentle Start", description: "Perfect for building a consistent habit", icon: "leaf.fill", color: Color.green),
        (range: 11...15, title: "Steady Progress", description: "Balanced approach for regular practice", icon: "chart.line.uptrend.xyaxis", color: Color.blue),
        (range: 16...20, title: "Committed Path", description: "For those ready to make significant progress", icon: "target", color: Color.orange),
        (range: 21...30, title: "Intensive Journey", description: "Ambitious goal for dedicated practitioners", icon: "flame.fill", color: Color.red)
    ]
    
    private var currentRecommendation: (range: ClosedRange<Int>, title: String, description: String, icon: String, color: Color)? {
        goalRecommendations.first { $0.range.contains(dailyGoal) }
    }
    
    // Calculate actual total debt using same logic as DebtCalculationView
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
            var totalDays = (bulkYears * 365) + (bulkMonths * 30) + bulkDays
            
            if gender == "Female" && averageCycleLength > 0 {
                let approximateMonths = Double(totalDays) / 30.44
                let totalMenstrualDays = Int(approximateMonths * Double(averageCycleLength))
                totalDays = max(0, totalDays - totalMenstrualDays)
            }
            return totalDays * 5
        case .custom:
            return customFajr + customDhuhr + customAsr + customMaghrib + customIsha
        }
    }
    
    private var estimatedCompletionTime: String {
        guard totalDebt > 0 && dailyGoal > 0 else {
            return "Set your goal to see estimate"
        }
        
        let days: Int
        
        if gender == "Female" && averageCycleLength > 0 {
            // For females, account for menstrual days when they can't work toward their goal
            let workingDaysPerMonth = 30 - averageCycleLength // Days they can pray toward their goal
            let monthlyProgress = dailyGoal * workingDaysPerMonth // Prayers completed per month
            
            if monthlyProgress <= 0 {
                return "Adjust your cycle length"
            }
            
            let totalMonths = totalDebt / monthlyProgress
            let remainingPrayers = totalDebt % monthlyProgress
            let extraDays = remainingPrayers / dailyGoal
            
            days = (totalMonths * 30) + extraDays
        } else {
            // For males, simple calculation
            days = totalDebt / dailyGoal
        }
        
        let months = days / 30
        
        if days < 30 {
            return "\(days) day\(days == 1 ? "" : "s")"
        } else if months < 12 {
            return "\(months) month\(months == 1 ? "" : "s")"
        } else {
            let years = months / 12
            let remainingMonths = months % 12
            if remainingMonths == 0 {
                return "\(years) year\(years == 1 ? "" : "s")"
            } else {
                return "\(years)y \(remainingMonths)m"
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        Spacer(minLength: 12)
                        
                        // Progress Indicator
                        HStack(spacing: 8) {
                            ForEach(0..<5) { index in
                                Circle()
                                    .fill(index == 3 ? Color.accentColor : Color.accentColor.opacity(0.2))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(index == 3 ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3), value: index == 3)
                            }
                        }
                        .modifier(FadeInOnAppearModifier(delay: 0.2, duration: 0.5))
                        .padding(.bottom, 16)
                        
                        // Title Section
                        VStack(spacing: 6) {
                            Text("Set Your Daily Goal")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text("Choose a sustainable target that fits your lifestyle")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .modifier(FadeInOnAppearModifier(delay: 0.4, duration: 0.6))
                    }
                    .frame(minHeight: geometry.size.height * 0.20)
                    
                    // Main Content
                    VStack(spacing: 24) {
                        // Current Goal Display
                        VStack(spacing: 20) {
                            // Large Goal Number
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [Color.accentColor.opacity(0.1), Color.accentColor.opacity(0.2)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 120, height: 120)
                                
                                VStack(spacing: 4) {
                                    Text("\(dailyGoal)")
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundColor(.accentColor)
                                    
                                    Text("prayers/day")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .modifier(FadeInOnAppearModifier(delay: 0.6, duration: 0.6))
                            
                            // Goal Recommendation Card
                            if let recommendation = currentRecommendation {
                                HStack(spacing: 16) {
                                    Image(systemName: recommendation.icon)
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(recommendation.color)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(recommendation.title)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        Text(recommendation.description)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.primary.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(recommendation.color.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .modifier(FadeInOnAppearModifier(delay: 0.8, duration: 0.6))
                            }
                        }
                        
                        // Goal Slider
                        VStack(spacing: 16) {
                            HStack {
                                Text("Adjust Your Goal")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("Est. completion: \(estimatedCompletionTime)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(Color.accentColor.opacity(0.1))
                                    )
                            }
                            
                            // Custom Slider
                            VStack(spacing: 12) {
                                Slider(value: Binding(
                                    get: { Double(dailyGoal) },
                                    set: { dailyGoal = Int($0) }
                                ), in: 5...30, step: 1) {
                                    Text("Daily Goal")
                                } minimumValueLabel: {
                                    Text("5")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                } maximumValueLabel: {
                                    Text("30")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .accentColor(.accentColor)
                                
                                // Quick Goal Buttons
                                HStack(spacing: 12) {
                                    ForEach(goalOptions, id: \.self) { goal in
                                        Button(action: {
                                            withAnimation(.spring(response: 0.3)) {
                                                dailyGoal = goal
                                            }
                                        }) {
                                            Text("\(goal)")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(dailyGoal == goal ? .white : .accentColor)
                                                .frame(width: 40, height: 32)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                        .fill(dailyGoal == goal ? Color.accentColor : Color.accentColor.opacity(0.1))
                                                )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        .modifier(FadeInOnAppearModifier(delay: 1.0, duration: 0.6))
                        
                        // Tips Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("💡 Tips for Success")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 12) {
                                TipRow(icon: "clock", text: "Start small and build consistency")
                                TipRow(icon: "calendar", text: "You can always adjust your goal later")
                                TipRow(icon: "heart", text: "Focus on spiritual growth, not just numbers")
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
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStep += 1
                                }
                            },
                            canGoBack: true,
                            canContinue: true
                        )
                        .padding(.top, 32)
                        .modifier(FadeInOnAppearModifier(delay: 1.0, duration: 0.6))
                        
                        // Bottom spacing
                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .onAppear {
            if !goalOptions.contains(dailyGoal) {
                dailyGoal = 5
            }
        }
    }
}

// MARK: - Tip Row Component
struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Spacer()
        }
    }
}