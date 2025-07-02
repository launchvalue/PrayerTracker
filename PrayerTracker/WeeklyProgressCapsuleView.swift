//
//  WeeklyProgressCapsuleView.swift
//  PrayerTracker
//
//  Created by Cascade on 7/2/25.
//

import SwiftUI
import SwiftData
import Foundation

/// A reusable weekly progress view that displays seven day capsules plus a slim progress bar
struct WeeklyProgressCapsuleView: View {
    let dailyGoal: Int
    let weeklyLogs: [DailyLog]
    
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Computed Properties
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var accentColor: Color {
        // Default accent color - can be customized via environment or settings
        .blue
    }
    
    private var weekDays: [Date] {
        let now = Date()
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else {
            return []
        }
        
        var days: [Date] = []
        var currentDate = weekInterval.start
        
        for _ in 0..<7 {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    private var totalPrayersLogged: Int {
        weeklyLogs.reduce(0) { $0 + $1.prayersCompleted }
    }
    
    private var weeklyGoal: Int {
        dailyGoal * 7
    }
    
    private var progressPercentage: Double {
        guard weeklyGoal > 0 else { return 0 }
        return min(Double(totalPrayersLogged) / Double(weeklyGoal), 1.0)
    }
    
    private func dayLog(for date: Date) -> DailyLog? {
        weeklyLogs.first { calendar.isDate($0.date, equalTo: date, toGranularity: .day) }
    }
    
    private func capsuleState(for date: Date) -> CapsuleState {
        let log = dayLog(for: date)
        let prayersLogged = log?.prayersCompleted ?? 0
        let isToday = calendar.isDateInToday(date)
        
        if prayersLogged == 0 {
            return .notMet(isToday: isToday)
        } else if prayersLogged > dailyGoal {
            return .exceeded(isToday: isToday)
        } else {
            return .met(isToday: isToday)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Week Progress Header
            HStack {
                Text("This Week")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(totalPrayersLogged)/\(weeklyGoal)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            // Capsules Row
            HStack(spacing: 8) {
                ForEach(weekDays, id: \.self) { day in
                    DayCapsuleView(
                        date: day,
                        state: capsuleState(for: day),
                        prayersLogged: dayLog(for: day)?.prayersCompleted ?? 0,
                        dailyGoal: dailyGoal,
                        accentColor: accentColor
                    )
                }
            }
            
            // Slim Progress Bar
            ProgressBarView(
                progress: progressPercentage,
                accentColor: accentColor
            )
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Supporting Views

private struct DayCapsuleView: View {
    let date: Date
    let state: CapsuleState
    let prayersLogged: Int
    let dailyGoal: Int
    let accentColor: Color
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date).prefix(1).uppercased() + formatter.string(from: date).dropFirst().lowercased()
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var accessibilityLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        let dateString = formatter.string(from: date)
        
        let stateDescription: String
        switch state {
        case .notMet:
            stateDescription = "goal not met"
        case .met:
            stateDescription = "goal met"
        case .exceeded:
            stateDescription = "goal exceeded"
        }
        
        return "\(dateString), \(stateDescription), \(prayersLogged) prayers logged"
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayLabel)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            ZStack {
                // Base capsule
                Capsule()
                    .fill(capsuleBackgroundColor)
                    .overlay(
                        Capsule()
                            .stroke(capsuleStrokeColor, lineWidth: capsuleStrokeWidth)
                    )
                
                // Exceeded indicator (inner ring or star)
                if case .exceeded = state {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(capsuleTextColor)
                }
                
                // Day number
                if case .notMet = state {
                    Text(dayNumber)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(capsuleTextColor)
                } else if !state.isExceeded {
                    Text(dayNumber)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(capsuleTextColor)
                }
            }
            .frame(width: 32, height: 44)
        }
        .accessibilityLabel(accessibilityLabel)
        .animation(.easeInOut(duration: 0.25), value: state)
    }
    
    // MARK: - Style Computed Properties
    
    private var capsuleBackgroundColor: Color {
        switch state {
        case .notMet:
            return accentColor.opacity(0.05)
        case .met, .exceeded:
            return accentColor.opacity(0.4)
        }
    }
    
    private var capsuleStrokeColor: Color {
        switch state {
        case .notMet(let isToday):
            return isToday ? accentColor : Color.gray.opacity(0.3)
        case .met(let isToday), .exceeded(let isToday):
            return isToday ? accentColor : Color.clear
        }
    }
    
    private var capsuleStrokeWidth: CGFloat {
        switch state {
        case .notMet(let isToday), .met(let isToday), .exceeded(let isToday):
            return isToday ? 2 : 1
        }
    }
    
    private var capsuleTextColor: Color {
        switch state {
        case .notMet:
            return .primary
        case .met, .exceeded:
            return .white
        }
    }
}

private struct ProgressBarView: View {
    let progress: Double
    let accentColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(accentColor.opacity(0.15))
                
                // Fill
                Capsule()
                    .fill(accentColor)
                    .frame(width: geometry.size.width * progress)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 6)
    }
}

// MARK: - Supporting Types

private enum CapsuleState: Equatable {
    case notMet(isToday: Bool)
    case met(isToday: Bool)
    case exceeded(isToday: Bool)
    
    var isToday: Bool {
        switch self {
        case .notMet(let isToday), .met(let isToday), .exceeded(let isToday):
            return isToday
        }
    }
    
    var isExceeded: Bool {
        if case .exceeded = self {
            return true
        }
        return false
    }
}



// MARK: - Preview

struct WeeklyProgressCapsuleView_Previews: PreviewProvider {
    static var previews: some View {
        let calendar = Calendar.current
        let today = Date()
        
        // Create sample logs for the current week
        let sampleLogs: [DailyLog] = [
            // Sunday - not met
            DailyLog(date: calendar.date(byAdding: .day, value: -6, to: today) ?? today, fajr: 1, dhuhr: 1, asr: 0, maghrib: 1, isha: 0),
            // Monday - met exactly
            DailyLog(date: calendar.date(byAdding: .day, value: -5, to: today) ?? today, fajr: 1, dhuhr: 1, asr: 1, maghrib: 1, isha: 1),
            // Tuesday - exceeded
            DailyLog(date: calendar.date(byAdding: .day, value: -4, to: today) ?? today, fajr: 2, dhuhr: 1, asr: 1, maghrib: 2, isha: 1),
            // Wednesday - not met
            DailyLog(date: calendar.date(byAdding: .day, value: -3, to: today) ?? today, fajr: 1, dhuhr: 0, asr: 1, maghrib: 0, isha: 1),
            // Thursday - exceeded
            DailyLog(date: calendar.date(byAdding: .day, value: -2, to: today) ?? today, fajr: 2, dhuhr: 2, asr: 1, maghrib: 1, isha: 2),
            // Friday - met exactly
            DailyLog(date: calendar.date(byAdding: .day, value: -1, to: today) ?? today, fajr: 1, dhuhr: 1, asr: 1, maghrib: 1, isha: 1),
            // Saturday (today) - partially met
            DailyLog(date: today, fajr: 1, dhuhr: 1, asr: 0, maghrib: 1, isha: 0)
        ]
        
        Group {
            // Light mode
            WeeklyProgressCapsuleView(
                dailyGoal: 5,
                weeklyLogs: sampleLogs
            )
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
            
            // Dark mode
            WeeklyProgressCapsuleView(
                dailyGoal: 5,
                weeklyLogs: sampleLogs
            )
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
            
            // Different goal
            WeeklyProgressCapsuleView(
                dailyGoal: 3,
                weeklyLogs: sampleLogs
            )
            .preferredColorScheme(.light)
            .previewDisplayName("Daily Goal: 3")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
