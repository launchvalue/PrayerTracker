import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(StatsService.self) private var statsService
    @Query private var userProfiles: [UserProfile]
    
    let userID: String
    
    init(userID: String) {
        self.userID = userID
        
        // Filter UserProfile by userID for data isolation
        self._userProfiles = Query(
            filter: #Predicate<UserProfile> { profile in
                profile.userID == userID
            }
        )
    }

    var body: some View {
        NavigationStack {
            AdaptiveScrollView {
                if statsService.isLoading {
                    VStack {
                        ProgressView("Loading statistics...")
                            .adaptivePadding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
                } else if statsService.hasError {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Unable to load statistics")
                            .font(.headline)
                        Text("Please try again")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("Retry") {
                            statsService.fetchData()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .adaptivePadding()
                    .transition(.opacity)
                } else if !userProfiles.isEmpty {
                    Grid(
                        horizontalSpacing: DesignSystem.Layout.gridSpacing,
                        verticalSpacing: DesignSystem.Layout.gridSpacing
                    ) {
                        GridRow {
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
                            .gridCellColumns(2)
                        }

                        GridRow {
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
                            .gridCellColumns(2)
                        }

                        GridRow {
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
                        }

                        GridRow {
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

                            NavigationLink(destination: HistoryView(userID: userID)) {
                                HStack {
                                    Image(systemName: "clock.arrow.circlepath")
                                    Text("View Full History")
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .adaptivePadding()
                                .background(
                                    .ultraThinMaterial,
                                    in: RoundedRectangle(cornerRadius: 12)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .adaptivePadding()
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .adaptivePadding()
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
            .animation(.easeOut(duration: 0.3), value: statsService.isLoading)
        }
    }
}

#Preview {
    StatsView(userID: "preview-user")
        .modelContainer(for: [UserProfile.self, PrayerDebt.self, DailyLog.self])
        .environment(StatsService(modelContext: ModelContext(try! ModelContainer(for: UserProfile.self, PrayerDebt.self, DailyLog.self)), userID: "preview-user"))
}