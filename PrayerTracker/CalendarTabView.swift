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
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Custom Header: Calendar Title
                VStack(alignment: .leading, spacing: 5) {
                    Text("Calendar")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.horizontal)
                .padding(.top, 20) // Adjusted top padding for overall screen

                CustomCalendarView(month: $displayedMonth) { date in
                    let log = logsByDate[date.startOfDay]
                    let isYesterday = Calendar.current.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
                    CalendarDayCell(date: date, log: log, dailyGoal: dailyGoal, isToday: Calendar.current.isDateInToday(date), isYesterdayMissed: isYesterday && wasYesterdayMissed())
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

                VStack(alignment: .leading) {
                    Text("History")
                        .font(.title2).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)

                    ForEach(logs.prefix(30)) { log in
                        HStack {
                            Text(log.date, format: .dateTime.month().day())
                            Spacer()
                            Text("\(log.prayersCompleted) / \(dailyGoal) completed")
                                .foregroundColor(.secondary)
                            if log.prayersCompleted >= dailyGoal {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }

                // Visual Key for Calendar Symbols
                VStack(alignment: .leading, spacing: 10) {
                    Text("Key")
                        .font(.title2).bold()
                        .padding(.leading)

                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Daily goal met")
                    }
                    .padding(.leading)

                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Daily goal exceeded")
                    }
                    .padding(.leading)

                    HStack {
                        Circle()
                            .stroke(Color.red, lineWidth: 2)
                            .frame(width: 20, height: 20)
                        Text("Yesterday's goal missed")
                    }
                    .padding(.leading)

                    HStack {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 20, height: 20)
                        Text("Today's date")
                    }
                    .padding(.leading)
                }
                .padding(.bottom) // Add padding to the bottom of the key
            }
            .padding(.horizontal, 16) // Apply horizontal padding to the main VStack
            .padding(.bottom, 20) // Add bottom padding to the main VStack
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
                        Image(systemName: log.prayersCompleted > dailyGoal ? "star.fill" : "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(log.prayersCompleted > dailyGoal ? .yellow : .green)
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