import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    let userProfile: UserProfile
    @Binding var prayerDebt: PrayerDebt

    @Query private var dailyLogs: [DailyLog]
    
    init(userProfile: UserProfile, prayerDebt: Binding<PrayerDebt>) {
        self.userProfile = userProfile
        self._prayerDebt = prayerDebt
        
        let userID = userProfile.userID
        
        // Filter DailyLog by userID for data isolation
        self._dailyLogs = Query(
            filter: #Predicate<DailyLog> { log in
                log.userID == userID
            },
            sort: \DailyLog.date,
            order: .reverse
        )
    }
    
    // State variables for log management
    @State private var todaysLog: DailyLog?
    @State private var logCreationError: Error?
    @State private var isCreatingLog = false

    private var totalRemaining: Int {
        prayerDebt.fajrOwed + prayerDebt.dhuhrOwed + prayerDebt.asrOwed + prayerDebt.maghribOwed + prayerDebt.ishaOwed
    }
    
    // MARK: - Log Management Functions
    
    private func ensureTodaysLog() {
        // Check if we already have today's log
        if let existingLog = dailyLogs.first(where: { Calendar.current.isDateInToday($0.date) }) {
            todaysLog = existingLog
            return
        }
        
        // Prevent duplicate creation attempts
        guard !isCreatingLog else { return }
        isCreatingLog = true
        
        // Create new log with proper error handling and userID for data isolation
        let newLog = DailyLog(userID: userProfile.userID, date: Date().startOfDay)
        modelContext.insert(newLog)
        
        do {
            try modelContext.save()
            todaysLog = newLog
            print("DailyLog created successfully in HomeView!")
        } catch {
            logCreationError = error
            modelContext.rollback() // Rollback failed transaction
            print("Failed to create DailyLog in HomeView: \(error.localizedDescription)")
        }
        
        isCreatingLog = false
    }

    private var prayersMadeUpThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())!.start
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())!.end

        return dailyLogs.filter { log in
            log.dateOnly >= startOfWeek && log.dateOnly < endOfWeek
        }.reduce(0) { $0 + $1.prayersCompleted }
    }
    
    private var currentWeekLogs: [DailyLog] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())!.start
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())!.end
        
        return dailyLogs.filter { log in
            log.dateOnly >= startOfWeek && log.dateOnly < endOfWeek
        }
    }

    private var progress: Double {
        guard userProfile.weeklyGoal > 0 else { return 0 }
        return Double(prayersMadeUpThisWeek) / Double(userProfile.weeklyGoal)
    }

    

    private func updatePrayerStatus(prayerName: String, log: DailyLog, profile: UserProfile) {
        switch prayerName {
        case "Fajr":
            if prayerDebt.fajrOwed > 0 {
                log.fajr += 1
                prayerDebt.fajrOwed -= 1
            }
        case "Dhuhr":
            if prayerDebt.dhuhrOwed > 0 {
                log.dhuhr += 1
                prayerDebt.dhuhrOwed -= 1
            }
        case "Asr":
            if prayerDebt.asrOwed > 0 {
                log.asr += 1
                prayerDebt.asrOwed -= 1
            }
        case "Maghrib":
            if prayerDebt.maghribOwed > 0 {
                log.maghrib += 1
                prayerDebt.maghribOwed -= 1
            }
        case "Isha":
            if prayerDebt.ishaOwed > 0 {
                log.isha += 1
                prayerDebt.ishaOwed -= 1
            }
        default:
            break
        }
        
        // Update daily streak after prayer completion
        updateDailyStreak(log: log, profile: profile)
        
        do {
            try modelContext.save()
            print("Prayer status updated and debt adjusted.")
        } catch {
            print("Failed to update prayer status or debt: \(error.localizedDescription)")
        }
    }
    
    /// Updates the user's daily streak based on daily goal completion
    private func updateDailyStreak(log: DailyLog, profile: UserProfile) {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Check if all daily prayers are completed
        if log.prayersCompleted >= profile.dailyGoal {
            // Prevent multiple updates for the same day
            if let lastUpdate = profile.lastStreakUpdate,
               Calendar.current.isDate(lastUpdate, inSameDayAs: today) {
                return // Already updated today
            }
            
            // Check streak continuity
            if let lastCompleted = profile.lastCompletedDate {
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
                if Calendar.current.isDate(lastCompleted, inSameDayAs: yesterday) {
                    profile.streak += 1 // Continue streak
                } else if Calendar.current.isDate(lastCompleted, inSameDayAs: today) {
                    // Same day, no change needed
                } else {
                    profile.streak = 1 // Reset streak after gap
                }
            } else {
                profile.streak = 1 // First completion
            }
            
            profile.lastStreakUpdate = today
            profile.lastCompletedDate = today
            profile.longestStreak = max(profile.longestStreak, profile.streak)
            
            print("Daily streak updated: \(profile.streak)")
        }
    }
    
    /// Checks for missed days and resets streak if necessary
    private func checkAndResetStreakForMissedDays(profile: UserProfile) {
        guard let lastCompleted = profile.lastCompletedDate else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        // If last completed date is not yesterday or today, reset streak
        if !Calendar.current.isDate(lastCompleted, inSameDayAs: yesterday) &&
           !Calendar.current.isDate(lastCompleted, inSameDayAs: today) {
            profile.streak = 0
            print("Streak reset due to missed days. Last completed: \(lastCompleted), Today: \(today)")
        }
    }
    
    /// One-time migration to reset inflated streaks from the old system
    private func migrateStreakData(profile: UserProfile) {
        // Check if migration is needed (if streak seems inflated)
        if profile.streak > 365 { // Reasonable threshold - no one has a 365+ day streak
            profile.streak = 0
            profile.lastStreakUpdate = nil
            profile.lastCompletedDate = nil
            print("Migrated inflated streak data. Reset to 0.")
            
            // Recalculate streak based on recent daily logs
            recalculateStreakFromHistory(profile: profile)
        }
    }
    
    /// Recalculates streak based on historical daily log data
    private func recalculateStreakFromHistory(profile: UserProfile) {
        let today = Calendar.current.startOfDay(for: Date())
        var currentStreak = 0
        var checkDate = today
        
        // Look back through recent logs to rebuild accurate streak
        for i in 0..<30 { // Check last 30 days
            if let dayLog = dailyLogs.first(where: { Calendar.current.isDate($0.dateOnly, inSameDayAs: checkDate) }) {
                if dayLog.prayersCompleted >= profile.dailyGoal {
                    currentStreak += 1
                } else {
                    break // Streak broken
                }
            } else {
                break // No log for this day, streak broken
            }
            
            guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }
        
        profile.streak = currentStreak
        if currentStreak > 0 {
            profile.lastCompletedDate = today
            profile.lastStreakUpdate = today
        }
        
        print("Recalculated streak from history: \(currentStreak)")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                // Header Section
                HeaderView(
                    userName: userProfile.name,
                    hijriDate: hijriDate
                )
                
                // Weekly Progress Section
                WeeklyProgressView(
                    userProfile: userProfile,
                    currentWeekLogs: currentWeekLogs
                )
                
                // Today's Log Section with Loading States
                TodaysLogView(
                    todaysLog: todaysLog,
                    isLoading: isCreatingLog,
                    error: logCreationError,
                    prayerDebt: $prayerDebt,
                    userProfile: userProfile,
                    onPrayerUpdate: updatePrayerStatus,
                    onRetry: ensureTodaysLog
                )
            }
            .padding(.bottom, DesignSystem.Spacing.lg)
        }
        .navigationBarHidden(true)
        .onAppear {
            // Clear any existing model object references to prevent context invalidation
            todaysLog = nil
            logCreationError = nil
            isCreatingLog = false
            
            ensureTodaysLog()
            
            // Perform streak management tasks
            migrateStreakData(profile: userProfile)
            checkAndResetStreakForMissedDays(profile: userProfile)
        }
        .alert("Error Creating Daily Log", isPresented: Binding(
            get: { logCreationError != nil },
            set: { _ in logCreationError = nil }
        )) {
            Button("OK") { }
        } message: {
            Text(logCreationError?.localizedDescription ?? "An unknown error occurred while creating today's prayer log.")
        }
    }

    /// Cached DateFormatter for Hijri dates to avoid repeated instantiation
    private static var hijriFormatterCache: [IslamicCalendarType: DateFormatter] = [:]
    
    /// Gets or creates a cached DateFormatter for the specified Islamic calendar type
    private static func getHijriFormatter(for calendarType: IslamicCalendarType) -> DateFormatter {
        if let cachedFormatter = hijriFormatterCache[calendarType] {
            return cachedFormatter
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: calendarType.calendarIdentifier)
        formatter.dateFormat = "d MMMM yyyy G"
        
        hijriFormatterCache[calendarType] = formatter
        return formatter
    }
    
    /// Computed property that returns the current date in Hijri format using user's preferred calendar
    private var hijriDate: String {
        let formatter = Self.getHijriFormatter(for: userProfile.islamicCalendarType)
        return formatter.string(from: Date())
    }
}