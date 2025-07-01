import SwiftUI

struct ProgressOverviewCard: View {
    let profile: UserProfile

    init(profile: UserProfile) {
        self.profile = profile
    }

    private var totalPrayersMadeUp: Int {
        guard let debt = profile.debt else { return 0 }
        return debt.totalInitialDebt - (debt.fajrOwed + debt.dhuhrOwed + debt.asrOwed + debt.maghribOwed + debt.ishaOwed)
    }

    private var totalInitialDebt: Int {
        profile.debt?.totalInitialDebt ?? 0
    }

    private var totalProgress: Double {
        guard totalInitialDebt > 0 else { return 0 }
        return Double(totalPrayersMadeUp) / Double(totalInitialDebt)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Progress")
                .font(.title2)
                .fontWeight(.bold)

            HStack(alignment: .bottom) {
                Gauge(value: totalProgress) {
                    Text("")
                } currentValueLabel: {
                    Text("\(Int(totalProgress * 100))%")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(.green)
                .frame(width: 100, height: 100)

                VStack(alignment: .leading) {
                    Text("Completed: \(totalPrayersMadeUp)")
                        .font(.headline)
                    Text("Remaining: \(totalInitialDebt - totalPrayersMadeUp)")
                        .font(.headline)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}