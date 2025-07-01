import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(StatsService.self) private var statsService
    @Query private var userProfiles: [UserProfile]

    var body: some View {
        NavigationStack {
            ScrollView {
                if let profile = userProfiles.first {
                    VStack(spacing: 15) {
                        // Overall Completion Card
                        VStack {
                            Text("Overall Completion")
                                .font(.headline)
                            Gauge(value: statsService.overallCompletionPercentage) {
                                Text("\(Int(statsService.overallCompletionPercentage * 100))%")
                            }
                            .gaugeStyle(.accessoryCircularCapacity)
                            .tint(.accentColor)
                            .frame(width: 100, height: 100)
                        }

                        // Debt Composition Chart
                        if let debt = profile.debt {
                            DebtCompositionChartView(prayerDebt: debt)
                        } else {
                            Text("No prayer debt data available.")
                                .foregroundColor(.secondary)
                                .padding()
                        }

                        // Prayer-Type Breakdown
                        VStack(alignment: .leading) {
                            Text("Prayer Breakdown")
                                .font(.headline)
                                .padding(.bottom, 5)
                            ForEach(statsService.prayerBreakdown, id: \.0.rawValue) { (prayerType, percentage, madeUp, initialOwed) in
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(prayerType.rawValue)
                                            .frame(width: 80, alignment: .leading)
                                        ProgressView(value: percentage)
                                            .tint(prayerType.color)
                                            .frame(height: 6)
                                        Text("\(madeUp)/\(initialOwed)")
                                            .frame(width: 60, alignment: .trailing)
                                    }
                                }
                            }
                        }

                        // Key Metrics & Streaks
                        VStack(alignment: .leading) {
                            Text("Key Metrics")
                                .font(.headline)
                                .padding(.bottom, 5)
                            HStack {
                                Text("Current Streak:")
                                Spacer()
                                Text("\(statsService.currentStreak) days")
                            }
                            HStack {
                                Text("Longest Streak:")
                                Spacer()
                                Text("\(statsService.longestStreak) days")
                            }
                            HStack {
                                Text("Best Day:")
                                Spacer()
                                Text("(\(statsService.bestDay?.prayersCompleted ?? 0) prayers)")
                            }
                        }

                        // Pace & Finish Forecast
                        VStack(alignment: .leading) {
                            Text("Pace & Forecast")
                                .font(.headline)
                                .padding(.bottom, 5)
                            HStack {
                                Text("Estimated Completion:")
                                Spacer()
                                Text(statsService.forecastDate)
                            }
                        }

                        // Weekly Goal Bar
                        VStack(alignment: .leading) {
                            Text("Weekly Goal")
                                .font(.headline)
                                .padding(.bottom, 5)
                            ProgressView(value: Double(statsService.weeklyBundles.completed), total: Double(statsService.weeklyBundles.goal)) {
                                Text("(\(statsService.weeklyBundles.completed) / \(statsService.weeklyBundles.goal) bundles)")
                            }
                            .tint(.orange)
                            .frame(height: 6)
                        }

                        // History Deep-Link
                        NavigationLink(destination: Text("Full History List")) { // Placeholder for HistoryLogView
                            Text("View Full History")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding()
                } else {
                    Text("No user profile found. Please complete the onboarding.")
                }
            }
            .navigationTitle("Statistics")
            .refreshable {
                statsService.fetchData()
            }
            .onAppear {
                statsService.fetchData()
            }
        }
    }
}

#Preview {
    StatsView()
        .modelContainer(for: [UserProfile.self, PrayerDebt.self, DailyLog.self])
        .environment(StatsService(modelContext: ModelContext(try! ModelContainer(for: UserProfile.self, PrayerDebt.self, DailyLog.self))))
}