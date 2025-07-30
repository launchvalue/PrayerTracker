import SwiftUI
import SwiftData
import Foundation

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
                
                // View Full History Navigation Card
                VStack(spacing: 16) {
                    NavigationLink(destination: HistoryView(userID: userID)) {
                        HStack(spacing: 16) {
                            // Icon with background
                            ZStack {
                                Circle()
                                    .fill(Color.accentColor.opacity(0.1))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.accentColor)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("View Full History")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text("Explore your prayer journey")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .opacity(0.6)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    .white.opacity(0.2),
                                                    .clear,
                                                    Color.accentColor.opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
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

// Enhanced Calendar Day Cell with Clean Design
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
    
    private var statusIcon: String? {
        if prayersCompleted >= dailyGoal {
            return "checkmark.circle.fill"
        }
        return nil
    }
    
    private var statusColor: Color {
        if prayersCompleted > dailyGoal {
            return .yellow
        } else if prayersCompleted >= dailyGoal {
            return .green
        } else {
            return .secondary
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            // Date Display with proper background handling
            ZStack {
                // Background circle for today or yesterday missed
                if isToday {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 32, height: 32)
                } else if isYesterdayMissed {
                    Circle()
                        .stroke(.red, lineWidth: 2)
                        .frame(width: 32, height: 32)
                }
                
                // Date text
                Text(date.formatted(.dateTime.day()))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(isToday ? .white : .primary)
            }
            .frame(width: 32, height: 32)
            
            // Prayer count with status icon (cleaner than progress bar)
            HStack(spacing: 2) {
                Text("\(prayersCompleted)/\(dailyGoal)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                
                if let icon = statusIcon {
                    Image(systemName: icon)
                        .font(.system(size: 8))
                        .foregroundStyle(statusColor)
                }
            }
        }
        .frame(width: 44, height: 50)
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