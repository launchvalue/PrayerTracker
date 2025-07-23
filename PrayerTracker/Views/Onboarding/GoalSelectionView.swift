import SwiftUI

struct GoalSelectionView: View {
    @Binding var dailyGoal: Int
    @Binding var currentStep: Int
    @State private var showContent = false
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
    
    private var estimatedCompletionTime: String {
        let averageDebt = 1000 // Rough estimate
        let days = averageDebt / dailyGoal
        let months = days / 30
        
        if months < 1 {
            return "\(days) days"
        } else if months < 12 {
            return "\(months) months"
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
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                        
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
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
                        
                        Spacer(minLength: 12)
                    }
                    .frame(minHeight: geometry.size.height * 0.25)
                    
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
                            .scaleEffect(showContent ? 1.0 : 0.8)
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: showContent)
                            
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
                                .opacity(showContent ? 1.0 : 0.0)
                                .offset(y: showContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.6).delay(0.8), value: showContent)
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
                                    ForEach([5, 10, 15, 20], id: \.self) { goal in
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
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(1.0), value: showContent)
                        
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
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(1.2), value: showContent)
                        
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
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6).delay(1.0), value: showContent)
                        
                        // Bottom spacing
                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            showContent = true
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