import SwiftUI
import SwiftData

struct CalendarTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var logs: [DailyLog]
    @Query private var userProfiles: [UserProfile]
    @State private var displayedMonth: Date = .now
    @State private var selectedLog: DailyLog? = nil
    
    let userID: String
    
    init(userID: String) {
        self.userID = userID
        
        // Filter DailyLog by userID for data isolation
        self._logs = Query(
            filter: #Predicate<DailyLog> { log in
                log.userID == userID
            },
            sort: \DailyLog.date,
            order: .reverse
        )
        
        // Filter UserProfile by userID for data isolation
        self._userProfiles = Query(
            filter: #Predicate<UserProfile> { profile in
                profile.userID == userID
            }
        )
    }
    
    private var dailyGoal: Int {
        userProfiles.first?.dailyGoal ?? 5
    }

    private var logsByDate: [Date: DailyLog] {
        Dictionary(logs.map { ($0.dateOnly, $0) }) { first, _ in first }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Standard Header
                Text("Calendar")
                    .font(.largeTitle.bold())
                    .padding(.horizontal, 20)
                    .padding(.top, 36)

                // Enhanced Calendar with Modern Design
                CustomCalendarView(month: $displayedMonth) { date in
                    let log = logsByDate[date.startOfDay]
                    let isYesterday = Calendar.current.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
                    EnhancedCalendarDayCell(date: date, log: log, dailyGoal: dailyGoal, isToday: Calendar.current.isDateInToday(date), isYesterdayMissed: isYesterday && wasYesterdayMissed())
                        .onTapGesture {
                            if let log = log {
                                selectedLog = log
                            } else {
                                let newLog = DailyLog(userID: userID, date: date)
                                modelContext.insert(newLog)
                                selectedLog = newLog
                            }
                        }
                }
                .padding(Edge.Set.horizontal, 16)

                // Enhanced History Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title3)
                            .foregroundStyle(.accent)
                        Text("Recent History")
                            .font(.title2.bold())
                    }
                    .padding(.horizontal, 20)

                    LazyVStack(spacing: 12) {
                        ForEach(logs.prefix(10)) { log in
                            EnhancedHistoryRow(log: log, dailyGoal: dailyGoal)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Enhanced Key Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .font(.title3)
                            .foregroundStyle(.accent)
                        Text("Legend")
                            .font(.title2.bold())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                    VStack(spacing: 12) {
                        EnhancedKeyItem(icon: "checkmark.circle.fill", iconColor: .green, text: "Daily goal achieved")
                        EnhancedKeyItem(icon: "star.fill", iconColor: .yellow, text: "Goal exceeded")
                        EnhancedKeyItem(icon: "circle", iconColor: .red, text: "Yesterday missed", isStroke: true)
                        EnhancedKeyItem(icon: "circle.fill", iconColor: Color.accentColor, text: "Today's date")
                    }
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true) // Hide default navigation bar
        .sheet(item: $selectedLog) { log in
            DailyLogDetailView(log: log, dailyGoal: dailyGoal)
        }
    }

    private func wasYesterdayMissed() -> Bool {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayLog = logsByDate[yesterday.startOfDay]
        return yesterdayLog == nil || yesterdayLog!.prayersCompleted < dailyGoal
    }
}

// Enhanced Calendar Day Cell with Modern Design
struct EnhancedCalendarDayCell: View {
    let date: Date
    let log: DailyLog?
    let dailyGoal: Int
    let isToday: Bool
    let isYesterdayMissed: Bool

    private var prayersCompleted: Int {
        log?.prayersCompleted ?? 0
    }
    
    private var progressPercentage: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(Double(prayersCompleted) / Double(dailyGoal), 1.0)
    }
    
    private var statusColor: Color {
        if prayersCompleted >= dailyGoal {
            return prayersCompleted > dailyGoal ? .yellow : .green
        } else if isYesterdayMissed {
            return .red
        } else {
            return .secondary
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            // Date Display - consistent size for all days
            Text(date.formatted(.dateTime.day()))
                .font(.caption.weight(.medium))
                .foregroundStyle(isToday ? Color.accentColor : .primary)
                .frame(width: 28, height: 28)
                .background {
                    // Only show red stroke for yesterday missed, no background for today
                    if isYesterdayMissed && !isToday {
                        Circle()
                            .stroke(.red, lineWidth: 1.5)
                    }
                }
            
            // Progress Indicator - more compact
            VStack(spacing: 1) {
                Text("\(prayersCompleted)/\(dailyGoal)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                // Progress Bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(.quaternary)
                    .frame(width: 20, height: 2)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(statusColor)
                            .frame(width: 20 * progressPercentage, height: 2)
                    }
            }
        }
        .frame(height: 45)
        .contentShape(Rectangle())
    }
}

// Enhanced History Row with Modern Design
struct EnhancedHistoryRow: View {
    let log: DailyLog
    let dailyGoal: Int
    
    private var progressPercentage: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(Double(log.prayersCompleted) / Double(dailyGoal), 1.0)
    }
    
    private var statusIcon: String {
        if log.prayersCompleted > dailyGoal {
            return "star.fill"
        } else if log.prayersCompleted >= dailyGoal {
            return "checkmark.circle.fill"
        } else {
            return "circle"
        }
    }
    
    private var statusColor: Color {
        if log.prayersCompleted > dailyGoal {
            return .yellow
        } else if log.prayersCompleted >= dailyGoal {
            return .green
        } else {
            return .secondary
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Date
            VStack(alignment: .leading, spacing: 2) {
                Text(log.date, format: .dateTime.weekday(.abbreviated))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(log.date, format: .dateTime.month().day())
                    .font(.headline.weight(.medium))
            }
            .frame(width: 50, alignment: .leading)
            
            // Progress Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(log.prayersCompleted) / \(dailyGoal) prayers")
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: statusIcon)
                        .font(.subheadline)
                        .foregroundStyle(statusColor)
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.quaternary)
                        .frame(height: 4)
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(statusColor)
                                .frame(width: max(0, geometry.size.width * progressPercentage), height: 4)
                                .animation(.easeInOut(duration: 0.3), value: progressPercentage)
                        }
                }
                .frame(height: 4)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// Enhanced Key Item for Legend
struct EnhancedKeyItem: View {
    let icon: String
    let iconColor: Color
    let text: String
    let isStroke: Bool
    
    init(icon: String, iconColor: Color, text: String, isStroke: Bool = false) {
        self.icon = icon
        self.iconColor = iconColor
        self.text = text
        self.isStroke = isStroke
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Group {
                if isStroke {
                    Image(systemName: icon)
                        .font(.subheadline)
                        .foregroundStyle(iconColor)
                        .overlay {
                            Circle()
                                .stroke(iconColor, lineWidth: 1.5)
                                .frame(width: 16, height: 16)
                        }
                } else {
                    Image(systemName: icon)
                        .font(.subheadline)
                        .foregroundStyle(iconColor)
                }
            }
            .frame(width: 20, height: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
            
            Spacer()
        }
    }
}

// Keep original for backward compatibility
struct CalendarDayCell: View {
    let date: Date
    let log: DailyLog?
    let dailyGoal: Int
    let isToday: Bool
    let isYesterdayMissed: Bool

    private var dotCount: Int {
        log?.dotCount(goal: dailyGoal) ?? 0
    }

    private var prayers: [PrayerType] {
        var completedPrayers: [PrayerType] = []
        if let log = log {
            if log.fajr > 0 { completedPrayers.append(.fajr) }
            if log.dhuhr > 0 { completedPrayers.append(.dhuhr) }
            if log.asr > 0 { completedPrayers.append(.asr) }
            if log.maghrib > 0 { completedPrayers.append(.maghrib) }
            if log.isha > 0 { completedPrayers.append(.isha) }
        }
        return completedPrayers
    }

    var body: some View {
        VStack {
            Text(date.formatted(.dateTime.day()))
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isToday ? .white : .primary)
                .frame(width: 36, height: 20) // Reduced height to make it more compact
                .background(
                    ZStack {
                        if isToday {
                            Circle().fill(Color.accentColor)
                        }
                        if isYesterdayMissed {
                            Circle().stroke(Color.red, lineWidth: 2)
                        }
                    }
                )
                .padding(.bottom, 0) // Reduced padding between date and goal

            VStack(spacing: 0) { // Reduced spacing to 0
                if let log = log {
                    Text("\(log.prayersCompleted)/\(dailyGoal)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    if log.prayersCompleted >= dailyGoal {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                } else {
                    // Placeholder for days with no log
                    Text("0/\(dailyGoal)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 15) // Adjusted frame height to be more compact and prevent overflow
        }
        .padding(.vertical, 2) // Add vertical padding to the cell content
    }

    private var accessibilityLabelForDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let dateString = formatter.string(from: date)
        
        switch dotCount {
        case 1:
            return "\(dateString), goal met."
        case 2:
            return "\(dateString), goal exceeded."
        default:
            return dateString
        }
    }
}