import SwiftUI
import SwiftData
import Combine

struct HistoryView: View {
    @Query private var dailyLogs: [DailyLog]
    @Environment(\.dismiss) private var dismiss
    
    let userID: String
    
    init(userID: String) {
        self.userID = userID
        
        // Filter DailyLog by userID for data isolation
        self._dailyLogs = Query(
            filter: #Predicate<DailyLog> { log in
                log.userID == userID
            },
            sort: \DailyLog.date,
            order: .reverse
        )
    }
    
    var body: some View {
        NavigationStack {
            List {
                if dailyLogs.isEmpty {
                    ContentUnavailableView(
                        "No Prayer History",
                        systemImage: "calendar.badge.clock",
                        description: Text("Start logging your daily prayers to see your history here.")
                    )
                } else {
                    ForEach(dailyLogs) { log in
                        HistoryRowView(dailyLog: log)
                    }
                }
            }
            .navigationTitle("Prayer History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HistoryRowView: View {
    let dailyLog: DailyLog
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private var prayerSummary: [(String, Int, Color)] {
        [
            ("Fajr", dailyLog.fajr, .blue),
            ("Dhuhr", dailyLog.dhuhr, .orange),
            ("Asr", dailyLog.asr, .yellow),
            ("Maghrib", dailyLog.maghrib, .red),
            ("Isha", dailyLog.isha, .purple)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date and total
            HStack {
                Text(dateFormatter.string(from: dailyLog.date))
                    .font(.headline)
                Spacer()
                Text("\(dailyLog.prayersCompleted) prayers")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Prayer breakdown
            HStack(spacing: 12) {
                ForEach(prayerSummary, id: \.0) { name, count, color in
                    VStack(spacing: 2) {
                        Text(name)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(count)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(count > 0 ? color : .secondary)
                    }
                    .frame(minWidth: 30)
                }
                Spacer()
            }
            
            // Notes if available
            if !dailyLog.notes.isEmpty {
                Text(dailyLog.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView(userID: "preview-user")
        .modelContainer(for: [DailyLog.self])
}
