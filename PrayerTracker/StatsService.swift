import Foundation
import SwiftData
import SwiftUI

@Observable
class StatsService {
    private var modelContext: ModelContext
    var logs: [DailyLog] = []
    var userProfile: UserProfile? = nil
    let userID: String
    
    // Loading and error state management
    var isLoading: Bool = false
    var hasError: Bool = false
    private var isFetching: Bool = false

    init(modelContext: ModelContext, userID: String) {
        self.modelContext = modelContext
        self.userID = userID
        fetchData()
    }

    func fetchData() {
        // Prevent concurrent fetch operations
        guard !isFetching else { return }
        
        isFetching = true
        isLoading = true
        hasError = false
        
        do {
            // Filter DailyLog by userID for data isolation
            let descriptor = FetchDescriptor<DailyLog>(
                predicate: #Predicate<DailyLog> { log in
                    log.userID == userID
                },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            logs = try modelContext.fetch(descriptor)

            // Filter UserProfile by userID for data isolation
            let profileDescriptor = FetchDescriptor<UserProfile>(
                predicate: #Predicate<UserProfile> { profile in
                    profile.userID == userID
                }
            )
            userProfile = try modelContext.fetch(profileDescriptor).first
            
            // Success - clear error state
            hasError = false
        } catch {
            print("Failed to fetch data for user \(userID): \(error)")
            // Reset to safe state on error
            logs = []
            userProfile = nil
            hasError = true
        }
        
        isLoading = false
        isFetching = false
    }

    var totalInitialDebt: Int {
        guard !hasError, let debt = userProfile?.debt else { return 0 }
        return debt.totalInitialDebt
    }

    var totalPrayersMadeUp: Int {
        guard !hasError, let debt = userProfile?.debt else { return 0 }
        let fajrMadeUp = max(0, debt.initialFajrOwed - debt.fajrOwed)
        let dhuhrMadeUp = max(0, debt.initialDhuhrOwed - debt.dhuhrOwed)
        let asrMadeUp = max(0, debt.initialAsrOwed - debt.asrOwed)
        let maghribMadeUp = max(0, debt.initialMaghribOwed - debt.maghribOwed)
        let ishaMadeUp = max(0, debt.initialIshaOwed - debt.ishaOwed)
        return fajrMadeUp + dhuhrMadeUp + asrMadeUp + maghribMadeUp + ishaMadeUp
    }

    var overallCompletionPercentage: Double {
        guard !hasError, !isLoading, totalInitialDebt > 0 else { return 0.0 }
        return Double(totalPrayersMadeUp) / Double(totalInitialDebt)
    }

    var prayerBreakdown: [(PrayerType, Double, Int, Int)] {
        guard let debt = userProfile?.debt else { 
            // Return safe default values for all prayer types
            return PrayerType.allCases.map { ($0, 0.0, 0, 0) }
        }

        return PrayerType.allCases.map {
            let initialOwed: Int
            let currentOwed: Int
            switch $0 {
            case .fajr: initialOwed = debt.initialFajrOwed; currentOwed = debt.fajrOwed
            case .dhuhr: initialOwed = debt.initialDhuhrOwed; currentOwed = debt.dhuhrOwed
            case .asr: initialOwed = debt.initialAsrOwed; currentOwed = debt.asrOwed
            case .maghrib: initialOwed = debt.initialMaghribOwed; currentOwed = debt.maghribOwed
            case .isha: initialOwed = debt.initialIshaOwed; currentOwed = debt.ishaOwed
            }
            let madeUp = max(0, initialOwed - currentOwed) // Ensure non-negative
            let totalForCalculation = madeUp + currentOwed
            return ($0, totalForCalculation > 0 ? (Double(madeUp) / Double(totalForCalculation)) : 0.0, madeUp, initialOwed)
        }
    }

    var currentStreak: Int {
        guard !hasError, !isLoading, let dailyGoal = userProfile?.dailyGoal, dailyGoal > 0, !logs.isEmpty else { return 0 }

        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())

        let sortedLogs = logs.sorted(by: { $0.dateOnly > $1.dateOnly }) // Sort descending

        for log in sortedLogs {
            if Calendar.current.isDate(log.dateOnly, inSameDayAs: currentDate) {
                if log.prayersCompleted >= dailyGoal {
                    streak += 1
                } else {
                    break // Goal not met for today, streak breaks
                }
            } else if let nextDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate), Calendar.current.isDate(log.dateOnly, inSameDayAs: nextDay) {
                // This handles gaps of one day where the previous day was logged
                if log.prayersCompleted >= dailyGoal {
                    streak += 1
                    currentDate = nextDay
                } else {
                    break
                }
            } else {
                break
            }
        }
        return streak
    }
    
    var currentWeekStreak: Int {
        guard !hasError, !isLoading, let dailyGoal = userProfile?.dailyGoal, dailyGoal > 0, !logs.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var weekStreak = 0
        
        // Start from the current week and work backwards
        var currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: Date())!.start
        
        while true {
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: currentWeekStart) else { break }
            
            // Get all days in this week
            var allDaysCompleted = true
            
            // Check each day of the week (7 days)
            for dayOffset in 0..<7 {
                guard let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: weekInterval.start) else {
                    allDaysCompleted = false
                    break
                }
                
                // Skip future dates
                if dayDate > Date() {
                    continue
                }
                
                // Find log for this day
                let dayLog = logs.first { calendar.isDate($0.dateOnly, inSameDayAs: dayDate) }
                
                // If no log or goal not met, week is incomplete
                if let log = dayLog {
                    if log.prayersCompleted < dailyGoal {
                        allDaysCompleted = false
                        break
                    }
                } else {
                    allDaysCompleted = false
                    break
                }
            }
            
            // If this week is complete, increment streak and continue to previous week
            if allDaysCompleted {
                weekStreak += 1
                // Move to previous week
                currentWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart)!
            } else {
                break
            }
        }
        
        return weekStreak
    }

    var longestStreak: Int {
        guard !hasError, !isLoading, let dailyGoal = userProfile?.dailyGoal, dailyGoal > 0, !logs.isEmpty else { return 0 }

        var maxStreak = 0
        var currentStreak = 0
        var previousDate: Date? = nil

        let sortedLogs = logs.sorted(by: { $0.dateOnly < $1.dateOnly }) // Sort ascending for longest streak

        for log in sortedLogs {
            if let prevDate = previousDate {
                if Calendar.current.isDate(log.dateOnly, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: prevDate)!) {
                    // Consecutive day
                    if log.prayersCompleted >= dailyGoal {
                        currentStreak += 1
                    } else {
                        currentStreak = 0 // Goal not met, reset streak
                    }
                } else if log.dateOnly > Calendar.current.date(byAdding: .day, value: 1, to: prevDate)! {
                    // Gap in days, start new streak
                    currentStreak = log.prayersCompleted >= dailyGoal ? 1 : 0
                } else {
                    // Same day or earlier day, do nothing (shouldn't happen with proper sorting)
                }
            } else {
                // First log, start streak
                currentStreak = log.prayersCompleted >= dailyGoal ? 1 : 0
            }
            maxStreak = max(maxStreak, currentStreak)
            previousDate = log.dateOnly
        }
        return maxStreak
    }

    var bestDay: DailyLog? {
        logs.max(by: { $0.prayersCompleted < $1.prayersCompleted })
    }

    var forecastDate: String {
        guard let profile = userProfile, let debt = profile.debt else { return "N/A" }
        
        let totalRemaining = max(0, debt.fajrOwed + debt.dhuhrOwed + debt.asrOwed + debt.maghribOwed + debt.ishaOwed)

        if totalRemaining <= 0 {
            return "All caught up!"
        }

        guard profile.dailyGoal > 0 else { return "Set daily goal to see forecast" }

        let calendar = Calendar.current
        let daysToCompletion = Double(totalRemaining) / Double(profile.dailyGoal)

        if let completionDate = calendar.date(byAdding: .day, value: Int(ceil(daysToCompletion)), to: Date()) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: completionDate)
        }
        return "Calculating..."
    }

    var weeklyBundles: (completed: Int, goal: Int) {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())!.start
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())!.end

        let bundlesCompletedThisWeek = logs.filter { log in
            log.dateOnly >= startOfWeek && log.dateOnly < endOfWeek
        }.reduce(0) { $0 + $1.prayersCompleted }

        return (bundlesCompletedThisWeek, userProfile?.weeklyGoal ?? 35)
    }

    var heatMapData: [Date: Int] {
        var data: [Date: Int] = [:]
        for log in logs {
            data[log.dateOnly] = log.dotCount(goal: dailyGoal)
        }
        return data
    }
    
    private var dailyGoal: Int {
        userProfile?.dailyGoal ?? 5
    }
}
