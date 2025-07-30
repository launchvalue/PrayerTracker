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
    
    // State variables for reset functionality
    @State private var showingResetConfirmation = false
    @State private var prayerToReset: String?

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

        // Break up the complex expression into sub-expressions
        let weekLogs = dailyLogs.filter { log in
            log.dateOnly >= startOfWeek && log.dateOnly < endOfWeek
        }
        
        let totalPrayers = weekLogs.reduce(0) { $0 + $1.prayersCompleted }
        return totalPrayers
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
    
    /// Resets the prayer count for today and restores debt
    private func resetPrayerCount(prayerName: String, log: DailyLog) {
        let currentCount = getPrayerCount(for: prayerName, from: log)
        
        // Only reset if there are prayers logged today
        guard currentCount > 0 else { return }
        
        switch prayerName {
        case "Fajr":
            prayerDebt.fajrOwed += log.fajr
            log.fajr = 0
        case "Dhuhr":
            prayerDebt.dhuhrOwed += log.dhuhr
            log.dhuhr = 0
        case "Asr":
            prayerDebt.asrOwed += log.asr
            log.asr = 0
        case "Maghrib":
            prayerDebt.maghribOwed += log.maghrib
            log.maghrib = 0
        case "Isha":
            prayerDebt.ishaOwed += log.isha
            log.isha = 0
        default:
            break
        }
        
        // Update daily streak after reset
        updateDailyStreak(log: log, profile: userProfile)
        
        do {
            try modelContext.save()
            print("Prayer count reset for \(prayerName). Debt restored.")
        } catch {
            print("Failed to reset prayer count: \(error.localizedDescription)")
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
        NavigationStack {
            ScrollView {
            VStack(spacing: 32) {
                // Professional header with proper spacing
                VStack(spacing: 20) {
                    // Status indicators row - refined and balanced
                    HStack {
                        // Hijri date pill
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            Text(hijriDate)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.quaternary.opacity(0.5), in: Capsule())
                        
                        Spacer()
                        
                        // Streak indicator pill
                        HStack(spacing: 8) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.orange)
                            Text("\(userProfile.streak) day\(userProfile.streak == 1 ? "" : "s")")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.orange.opacity(0.1), in: Capsule())
                    }
                    .padding(.horizontal, 24)
                    
                    // Main greeting section - properly spaced
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Assalamu Alaikum")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(userProfile.name.isEmpty ? "User" : userProfile.name)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 24)
                
                // Weekly Overview - MOVED TO TOP
                VStack(spacing: 16) {
                    HStack {
                        Text("This Week's Progress")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(prayersMadeUpThisWeek)/\(userProfile.weeklyGoal)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .scaleEffect(y: 2)
                    
                    WeeklyCalendarView(logs: currentWeekLogs, dailyGoal: userProfile.dailyGoal)
                }
                .padding(20)
                .standardCardBackground()
                .padding(.horizontal, 20)
                
                // Prayer Logging Interface - CLEAN MINIMAL DESIGN
                if let log = todaysLog {
                    // Clean header with inline remaining count
                    HStack {
                        Text("Track Your Prayer Debt")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Inline remaining count
                        if totalRemaining > 0 {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 4, height: 4)
                                
                                Text("\(totalRemaining) remaining")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 4, height: 4)
                                
                                Text("All caught up")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Floating prayer cards with glassmorphism effect
                    VStack(spacing: 8) {
                        ForEach(["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"], id: \.self) { prayer in
                            FloatingPrayerCard(
                                prayer: prayer,
                                todayCount: getPrayerCount(for: prayer, from: log),
                                debtCount: getPrayerDebtCount(for: prayer),
                                isEnabled: getPrayerDebtCount(for: prayer) > 0,
                                color: getPrayerColor(for: prayer),
                                hasMetDailyGoal: log.prayersCompleted >= userProfile.dailyGoal,
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        updatePrayerStatus(prayerName: prayer, log: log, profile: userProfile)
                                    }
                                },
                                onLongPress: {
                                    // Only allow reset if prayers have been logged today
                                    if getPrayerCount(for: prayer, from: log) > 0 {
                                        prayerToReset = prayer
                                        showingResetConfirmation = true
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                } else if isCreatingLog {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Preparing...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 40)
                }
                
                Spacer(minLength: 20)
            }
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
        .alert("Reset Prayer Count?", isPresented: $showingResetConfirmation) {
            Button("Reset", role: .destructive) {
                if let prayer = prayerToReset, let log = todaysLog {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        resetPrayerCount(prayerName: prayer, log: log)
                    }
                }
                prayerToReset = nil
            }
            Button("Cancel", role: .cancel) {
                prayerToReset = nil
            }
        } message: {
            if let prayer = prayerToReset, let log = todaysLog {
                let count = getPrayerCount(for: prayer, from: log)
                Text("This will reset today's \(prayer) count to 0 and restore \(count) \(count == 1 ? "prayer" : "prayers") to your debt. This action cannot be undone.")
            }
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
        case "Fajr": return .green
        case "Dhuhr": return .blue
        case "Asr": return .orange
        case "Maghrib": return .purple
        case "Isha": return .indigo
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

struct FloatingPrayerCard: View {
    let prayer: String
    let todayCount: Int
    let debtCount: Int
    let isEnabled: Bool
    let color: Color
    let hasMetDailyGoal: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 0) {
                // Left side - Prayer info with gradient accent
                HStack(spacing: 12) {
                    // Animated color indicator
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: isEnabled ? [color, color.opacity(0.6)] : [.gray, .gray.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 4, height: 32)
                        .scaleEffect(y: isPressed ? 1.2 : 1.0)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 8) {
                            Text(prayer)
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            // Visual status indicators
                            HStack(spacing: 4) {
                                if todayCount > 0 {
                                    // Show logged prayers as filled circles
                                    ForEach(0..<min(todayCount, 5), id: \.self) { _ in
                                        Circle()
                                            .fill(color)
                                            .frame(width: 6, height: 6)
                                    }
                                    
                                    // Show exceeded count if more than 5
                                    if todayCount > 5 {
                                        Text("+\(todayCount - 5)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(color)
                                    }
                                }
                                
                                // Goal exceeded indicator
                                if todayCount > 1 {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        
                        if isEnabled {
                            Text("\(debtCount) to make up")
                                .font(.caption)
                                .foregroundColor(color)
                                .fontWeight(.medium)
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                
                                Text("Complete")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Right side - Minimal action indicator
                HStack(spacing: 16) {
                    if isEnabled {
                        // Minimal plus icon - changes color based on goal completion
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(hasMetDailyGoal ? .green : color)
                            .opacity(isPressed ? 0.6 : 1.0)
                            .scaleEffect(isPressed ? 0.9 : 1.0)
                    } else {
                        // Completed state with subtle checkmark
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.green)
                            .opacity(0.8)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .enhancedCardBackground(color: isEnabled ? color : .clear)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        .disabled(!isEnabled)
        .onTapGesture {
            if isEnabled {
                onTap()
            }
        }
        .onLongPressGesture(minimumDuration: 0.6, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {
            // Long press action for reset
            onLongPress()
        })
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
                        .fontWeight(isToday ? .semibold : .medium)
                        .foregroundColor(isToday ? .accentColor : .secondary)
                    
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.subheadline)
                        .fontWeight(isToday ? .bold : .medium)
                        .foregroundColor(isToday ? .accentColor : (isCompleted ? .green : .secondary))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isCompleted && !isToday ? Color.green.opacity(0.1) : Color.clear)
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