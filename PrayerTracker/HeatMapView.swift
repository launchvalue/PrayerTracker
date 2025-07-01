import SwiftUI

struct HeatMapView: View {
    let data: [Date: Int]
    let month: Date

    private var days: [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else {
            return []
        }

        let firstDayOfMonth = monthInterval.start
        let weekdayOfFirstDay = calendar.component(.weekday, from: firstDayOfMonth)
        let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count

        var days: [Date] = []

        for i in 1..<weekdayOfFirstDay {
            days.append(Date(timeIntervalSince1970: Double(i * -1)))
        }

        for dayOffset in 0..<numberOfDaysInMonth {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack {
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(days, id: \.self) { date in
                    if date.timeIntervalSince1970 < 0 {
                        Color.clear
                            .frame(width: 20, height: 20)
                    } else {
                        let dotCount = data[date.startOfDay] ?? 0
                        Circle()
                            .fill(fillColor(for: dotCount))
                            .frame(width: 20, height: 20)
                    }
                }
            }
        }
    }

    private func fillColor(for dotCount: Int) -> Color {
        switch dotCount {
        case 1: return .accentColor.opacity(0.3)
        case 2: return .accentColor.opacity(0.6)
        default: return .clear
        }
    }
}
