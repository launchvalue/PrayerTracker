import SwiftUI

struct CustomCalendarView<Content: View>: View {
    @Binding var month: Date
    @ViewBuilder let content: (Date) -> Content

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
    
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        VStack {
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(month, format: .dateTime.month().year())
                    .font(.headline)
                Spacer()
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.vertical, 10) // Control vertical spacing of month navigation

            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) { // Further reduced spacing
                ForEach(days, id: \.self) { date in
                    if date.timeIntervalSince1970 < 0 {
                        Color.clear
                    } else {
                        content(date)
                    }
                }
            }
        }
        .padding(.all, 16) // Apply consistent internal padding
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func changeMonth(by amount: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: amount, to: month) {
            month = newMonth
        }
    }
}
