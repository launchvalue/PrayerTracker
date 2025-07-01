import Foundation
import SwiftData
import SwiftUI

@Observable
class StatsService {
    private var modelContext: ModelContext
    var logs: [DailyLog] = []
    var userProfile: UserProfile? = nil

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchData()
    }

    func fetchData() {
        do {
            let descriptor = FetchDescriptor<DailyLog>(sortBy: [SortDescriptor(\.date, order: .reverse)])
            logs = try modelContext.fetch(descriptor)

            let profileDescriptor = FetchDescriptor<UserProfile>()
            userProfile = try modelContext.fetch(profileDescriptor).first
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }

    var totalInitialDebt: Int {
        userProfile?.debt?.totalInitialDebt ?? 0
    }

    var totalPrayersMadeUp: Int {
        guard let debt = userProfile?.debt else { return 0 }
        return debt.initialFajrOwed - debt.fajrOwed + debt.initialDhuhrOwed - debt.dhuhrOwed + debt.initialAsrOwed - debt.asrOwed + debt.initialMaghribOwed - debt.maghribOwed + debt.initialIshaOwed - debt.ishaOwed
    }

    var overallCompletionPercentage: Double {
        guard totalInitialDebt > 0 else { return 0.0 }
        return Double(totalPrayersMadeUp) / Double(totalInitialDebt)
    }

    var prayerBreakdown: [(PrayerType, Double, Int, Int)] {
        guard let debt = userProfile?.debt else { return [] }

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
            let madeUp = initialOwed - currentOwed
            let totalForCalculation = madeUp + currentOwed
            return ($0, totalForCalculation > 0 ? (Double(madeUp) / Double(totalForCalculation)) : 0.0, madeUp, initialOwed)
        }
    }

    var currentStreak: Int {
        guard let dailyGoal = userProfile?.dailyGoal, !logs.isEmpty else { return 0 }

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

    var longestStreak: Int {
        guard let dailyGoal = userProfile?.dailyGoal, !logs.isEmpty else { return 0 }

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
        let totalRemaining = debt.fajrOwed + debt.dhuhrOwed + debt.asrOwed + debt.maghribOwed + debt.ishaOwed

        if totalRemaining <= 0 {
            return "All caught up!"
        }

        let calendar = Calendar.current
        let daysToCompletion = Double(totalRemaining) / Double(profile.dailyGoal)

        guard profile.dailyGoal > 0 else { return "Calculating..." }

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
