import SwiftUI
import Charts

struct PrayerBreakdownChart: View {
    let profile: UserProfile

    private func prayerBreakdownData(profile: UserProfile) -> [PrayerData] {
        guard let debt = profile.debt else { return [] }

        return [
            PrayerData(prayerName: "Fajr", owed: debt.fajrOwed, initialOwed: debt.initialFajrOwed),
            PrayerData(prayerName: "Dhuhr", owed: debt.dhuhrOwed, initialOwed: debt.initialDhuhrOwed),
            PrayerData(prayerName: "Asr", owed: debt.asrOwed, initialOwed: debt.initialAsrOwed),
            PrayerData(prayerName: "Maghrib", owed: debt.maghribOwed, initialOwed: debt.initialMaghribOwed),
            PrayerData(prayerName: "Isha", owed: debt.ishaOwed, initialOwed: debt.initialIshaOwed)
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Prayer Type Breakdown")
                .font(.title2)
                .fontWeight(.bold)

            Chart {
                ForEach(prayerBreakdownData(profile: profile)) { data in
                    BarMark(x: .value("Prayer", data.prayerName),
                            y: .value("Percentage", data.percentage))
                    .foregroundStyle(by: .value("Prayer", data.prayerName))
                }
            }
            .chartXAxis { // Hide X-axis labels
                AxisMarks(values: .automatic) {
                    AxisValueLabel()
                }
            }
            .chartYAxis { // Hide Y-axis labels
                AxisMarks(values: .automatic) {
                    AxisValueLabel()
                }
            }
            .frame(height: 200)
            .padding()
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct PrayerData: Identifiable {
    let id = UUID()
    let prayerName: String
    let owed: Int
    let initialOwed: Int

    var percentage: Double {
        guard initialOwed > 0 else { return 0 }
        return Double(initialOwed - owed) / Double(initialOwed)
    }
}