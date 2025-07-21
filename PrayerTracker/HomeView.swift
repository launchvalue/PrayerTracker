import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    let userProfile: UserProfile
    @Bindable var prayerDebt: PrayerDebt

    @Query private var dailyLogs: [DailyLog]
    
    init(userProfile: UserProfile, prayerDebt: PrayerDebt) {
        self.userProfile = userProfile
        self.prayerDebt = prayerDebt
        
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
        for _ in 0..<30 { // Check last 30 days
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
            VStack(spacing: 24) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Assalamu Alaikum")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Text(userProfile.name.isEmpty ? "User" : userProfile.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(hijriDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("🔥 \(userProfile.streak)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Weekly Overview - MOVED TO TOP
                VStack(spacing: 16) {
                    HStack {
                        Text("This Week")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(prayersMadeUpThisWeek)/\(userProfile.weeklyGoal)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(y: 2)
                    
                    WeeklyCalendarView(logs: currentWeekLogs, dailyGoal: userProfile.dailyGoal)
                }
                .padding(20)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                // Prayer Logging Interface - COMBINED SECTION
                if let log = todaysLog {
                    VStack(spacing: 20) {
                        // Header with clear call-to-action
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                                
                                Text("Log Your Prayers")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Text("\(log.prayersCompleted) today")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(12)
                            }
                            
                            Text("Tap a prayer to log it and reduce your debt")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Prayer buttons with debt information
                        VStack(spacing: 12) {
                            ForEach(["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"], id: \.self) { prayer in
                                PrayerLogButton(
                                    prayer: prayer,
                                    todayCount: getPrayerCount(for: prayer, from: log),
                                    debtCount: getPrayerDebtCount(for: prayer),
                                    isEnabled: getPrayerDebtCount(for: prayer) > 0,
                                    color: getPrayerColor(for: prayer),
                                    onTap: {
                                        updatePrayerStatus(prayerName: prayer, log: log, profile: userProfile)
                                    }
                                )
                            }
                        }
                        
                        // Summary footer
                        if totalRemaining > 0 {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundColor(.orange)
                                
                                Text("\(totalRemaining) prayers remaining to make up")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                            .padding(.top, 8)
                        } else {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                
                                Text("All prayers caught up! 🎉")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .fontWeight(.medium)
                                
                                Spacer()
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 20)
                } else if isCreatingLog {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Setting up today's log...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(20)
                }
                
                Spacer(minLength: 20)
            }
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
    
    // MARK: - Helper Functions for New UI
    
    private func getPrayerCount(for prayer: String, from log: DailyLog) -> Int {
        switch prayer {
        case "Fajr": return log.fajr
        case "Dhuhr": return log.dhuhr
        case "Asr": return log.asr
        case "Maghrib": return log.maghrib
        case "Isha": return log.isha
        default: return 0
        }
    }
    
    private func getPrayerDebtCount(for prayer: String) -> Int {
        switch prayer {
        case "Fajr": return prayerDebt.fajrOwed
        case "Dhuhr": return prayerDebt.dhuhrOwed
        case "Asr": return prayerDebt.asrOwed
        case "Maghrib": return prayerDebt.maghribOwed
        case "Isha": return prayerDebt.ishaOwed
        default: return 0
        }
    }
    
    private func getPrayerColor(for prayer: String) -> Color {
        switch prayer {
        case "Fajr": return .blue
        case "Dhuhr": return .orange
        case "Asr": return .yellow
        case "Maghrib": return .pink
        case "Isha": return .purple
        default: return .gray
        }
    }
}

// MARK: - Custom UI Components

struct PrayerDebtCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct PrayerLogButton: View {
    let prayer: String
    let todayCount: Int
    let debtCount: Int
    let isEnabled: Bool
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Prayer name and icon
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Circle()
                            .fill(color)
                            .frame(width: 12, height: 12)
                        
                        Text(prayer)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    if isEnabled {
                        Text("Tap to log prayer")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } else {
                        Text("All caught up!")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                // Stats section
                HStack(spacing: 16) {
                    // Today's count
                    VStack(alignment: .center, spacing: 2) {
                        Text("\(todayCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("today")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    // Debt count
                    VStack(alignment: .center, spacing: 2) {
                        Text("\(debtCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(debtCount > 0 ? color : .green)
                        
                        Text("owed")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    // Action indicator
                    if isEnabled {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? color.opacity(0.05) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isEnabled ? color.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .disabled(!isEnabled)
        .buttonStyle(PlainButtonStyle())
    }
}

struct WeeklyCalendarView: View {
    let logs: [DailyLog]
    let dailyGoal: Int
    
    private var weekDays: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())!.start
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(weekDays, id: \.self) { date in
                let dayLog = logs.first { Calendar.current.isDate($0.dateOnly, inSameDayAs: date) }
                let isCompleted = (dayLog?.prayersCompleted ?? 0) >= dailyGoal
                let isToday = Calendar.current.isDateInToday(date)
                
                VStack(spacing: 4) {
                    Text(DateFormatter.dayFormatter.string(from: date))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.subheadline)
                        .fontWeight(isToday ? .bold : .medium)
                        .foregroundColor(isToday ? .primary : .secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    Circle()
                        .fill(isCompleted ? Color.green.opacity(0.2) : Color.clear)
                        .overlay(
                            Circle()
                                .stroke(isToday ? Color.blue : Color.clear, lineWidth: 2)
                        )
                )
            }
        }
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
}