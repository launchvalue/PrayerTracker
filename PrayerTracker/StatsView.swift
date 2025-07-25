import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(StatsService.self) private var statsService
    @Query private var userProfiles: [UserProfile]
    
    let userID: String
    @State private var showContent = false
    
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
            ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                            // Title Section - Full Width
                            HStack {
                                Text("Your Progress")
                                    .font(.largeTitle.bold())
                                    .foregroundColor(.primary)
                                    .padding(.top, 50)
                                    .padding(.leading, 20)
                                    .opacity(showContent ? 1 : 0)
                                    .animation(.easeOut(duration: 0.6), value: showContent)
                                Spacer()
                            }
                            
                            // Header Section - Compact
                            VStack(spacing: 8) {
                                
                                // Hero Stats Section - Left Aligned
                                VStack(alignment: .leading, spacing: 16) {
                                    
                                    if !statsService.isLoading && !statsService.hasError && !userProfiles.isEmpty {
                                        HStack(spacing: 32) {
                                            // Overall Progress
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text("\(Int(statsService.overallCompletionPercentage * 100))%")
                                                    .font(.system(size: 44, weight: .bold, design: .rounded))
                                                    .foregroundColor(.primary)
                                                    .minimumScaleFactor(0.8)
                                                    .lineLimit(1)
                                                
                                                Text("Complete")
                                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                                    .foregroundColor(.secondary)
                                                    .minimumScaleFactor(0.9)
                                                    .lineLimit(1)
                                            }
                                            
                                            // Current Streak
                                            VStack(alignment: .leading, spacing: 6) {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "flame.fill")
                                                        .font(.system(size: 20, weight: .medium))
                                                        .foregroundColor(.orange)
                                                    
                                                    Text("\(statsService.currentStreak)")
                                                        .font(.system(size: 44, weight: .bold, design: .rounded))
                                                        .foregroundColor(.primary)
                                                        .minimumScaleFactor(0.8)
                                                        .lineLimit(1)
                                                }
                                                
                                                Text("Day Streak")
                                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                                    .foregroundColor(.secondary)
                                                    .minimumScaleFactor(0.9)
                                                    .lineLimit(1)
                                            }
                                            
                                            Spacer()
                                        }
                                        .opacity(showContent ? 1 : 0)
                                        .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)
                                    }
                                }
                                .padding(.horizontal, AppSpacing.large)
                            }
                            
                            // Content Section
                            VStack(spacing: 16) {
                                if statsService.isLoading {
                                    VStack(spacing: 16) {
                                        ProgressView()
                                            .scaleEffect(1.2)
                                            .tint(.accentColor)
                                        
                                        Text("Loading your stats...")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 60)
                                    .transition(.opacity)
                                    
                                } else if statsService.hasError {
                                    VStack(spacing: 20) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.system(size: 48))
                                            .foregroundColor(.orange)
                                        
                                        VStack(spacing: 8) {
                                            Text("Unable to load statistics")
                                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                                .foregroundColor(.primary)
                                            
                                            Text("Please check your connection and try again")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.center)
                                        }
                                        
                                        Button(action: { statsService.fetchData() }) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "arrow.clockwise")
                                                Text("Retry")
                                            }
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 12)
                                            .background(
                                                LinearGradient(
                                                    colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                in: RoundedRectangle(cornerRadius: 25, style: .continuous)
                                            )
                                            .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 40)
                                    .transition(.opacity)
                                    
                                } else if !userProfiles.isEmpty {
                                    // Key Stats - Unified Card
                                    VStack(spacing: 16) {
                                        HStack {
                                            Text("Key Stats")
                                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                                .foregroundColor(.primary)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 24)
                                        .opacity(showContent ? 1 : 0)
                                        .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
                                        
                                        // Single unified stats card
                                        HStack(spacing: 0) {
                                            // Best Streak
                                            VStack(spacing: 8) {
                                                Text("\(statsService.longestStreak)")
                                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                                    .foregroundColor(.primary)
                                                
                                                Text("Best Streak")
                                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                                    .foregroundColor(.secondary)
                                            }
                                            .frame(maxWidth: .infinity)
                                            
                                            // Divider
                                            Rectangle()
                                                .fill(Color.primary.opacity(0.1))
                                                .frame(width: 1, height: 60)
                                            
                                            // Best Day
                                            VStack(spacing: 8) {
                                                Text("\(statsService.bestDay?.prayersCompleted ?? 0)")
                                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                                    .foregroundColor(.primary)
                                                
                                                Text("Best Day")
                                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                                    .foregroundColor(.secondary)
                                            }
                                            .frame(maxWidth: .infinity)
                                            
                                            // Divider
                                            Rectangle()
                                                .fill(Color.primary.opacity(0.1))
                                                .frame(width: 1, height: 60)
                                            
                                            // Completion
                                            VStack(spacing: 8) {
                                                Text(statsService.forecastDate.components(separatedBy: " ").first ?? "Soon")
                                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                                    .foregroundColor(.primary)
                                                
                                                Text("Completion")
                                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                                    .foregroundColor(.secondary)
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                        .padding(24)
                                        .standardCardBackgroundWithShadow(cornerRadius: 20)
                                        .padding(.horizontal, 24)
                                        .opacity(showContent ? 1 : 0)
                                        .animation(.easeOut(duration: 0.6).delay(0.5), value: showContent)
                                    }
                                    
                                    // Remaining Prayers - Minimal List
                                    VStack(spacing: 16) {
                                        HStack {
                                            Text("Remaining Prayers")
                                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                                .foregroundColor(.primary)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 24)
                                        .opacity(showContent ? 1 : 0)
                                        .animation(.easeOut(duration: 0.6).delay(0.6), value: showContent)
                                        
                                        // Compact prayer list
                                        VStack(spacing: 0) {
                                            ForEach(Array(statsService.prayerBreakdown.enumerated()), id: \.offset) { index, breakdown in
                                                let (prayerType, _, madeUp, initialOwed) = breakdown
                                                let remaining = initialOwed - madeUp
                                                
                                                HStack {
                                                    // Prayer name
                                                    Text(prayerType.rawValue)
                                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                                        .foregroundColor(.primary)
                                                    
                                                    Spacer()
                                                    
                                                    // Remaining count
                                                    Text("\(remaining)")
                                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                        .foregroundColor(.secondary)
                                                    
                                                    // Color indicator
                                                    Circle()
                                                        .fill(prayerType.color)
                                                        .frame(width: 8, height: 8)
                                                }
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 12)
                                                .background(
                                                    index % 2 == 0 ? Color.clear : Color.primary.opacity(0.02)
                                                )
                                                .opacity(showContent ? 1 : 0)
                                                .animation(.easeOut(duration: 0.6).delay(0.7 + Double(index) * 0.1), value: showContent)
                                            }
                                        }
                                        .standardCardBackgroundWithShadow()
                                        .padding(.horizontal, 24)
                                    }
                                    
                                    // History Navigation Card
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
                                            .shadow(color: Color.primary.opacity(0.1), radius: 8, x: 0, y: 4)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.horizontal, 24)
                                        .opacity(showContent ? 1 : 0)
                                        .animation(.easeOut(duration: 0.6).delay(1.5), value: showContent)
                                    }
                                    
                                } else {
                                    VStack(spacing: 20) {
                                        Image(systemName: "person.crop.circle.badge.questionmark")
                                            .font(.system(size: 48))
                                            .foregroundColor(.secondary)
                                        
                                        Text("Complete onboarding to view statistics")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 60)
                                }
                                
                                // Bottom padding for safe area
                                Spacer(minLength: 40)
                            }
                        }
            }
            .scrollIndicators(.hidden)
            .refreshable {
                statsService.fetchData()
            }
            .onAppear {
                statsService.fetchData()
                withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
                    showContent = true
                }
            }
            .animation(.easeOut(duration: 0.3), value: statsService.isLoading)
        }
    }
}

// MARK: - Custom Components

struct PrayerProgressCard: View {
    let prayerType: PrayerType
    let percentage: Double
    let madeUp: Int
    let initialOwed: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Prayer type indicator
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(prayerType.color.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "moon.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(prayerType.color)
                }
                
                Text(prayerType.rawValue)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Progress bar
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(madeUp) / \(initialOwed)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(Int(percentage * 100))%")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color.primary.opacity(0.1))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [prayerType.color, prayerType.color.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * percentage, height: 8)
                                .animation(.spring(duration: 1.0).delay(0.2), value: percentage)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.2),
                                    .clear,
                                    prayerType.color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.primary.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct StatsMetricCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Icon with subtle glow effect
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(iconColor)
                    .shadow(color: iconColor.opacity(0.3), radius: 8, x: 0, y: 0)
                Spacer()
            }
            .padding(.bottom, 16)
            
            // Main value with emphasis
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Spacer()
            }
            
            Spacer()
            
            // Title at bottom
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(iconColor.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.primary.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

struct WeeklyGoalCard: View {
    let completed: Int
    let goal: Int
    
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return Double(completed) / Double(goal)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Icon at top
            HStack {
                Image(systemName: "target")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.orange)
                    .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 0)
                Spacer()
            }
            .padding(.bottom, 16)
            
            // Progress value
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(completed)/\(goal)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    Text("bundles")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(.bottom, 16)
            
            // Prominent progress bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.primary.opacity(0.1))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.orange.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 12)
                            .animation(.spring(duration: 1.2).delay(0.3), value: progress)
                    }
                }
                .frame(height: 12)
                
                // Title below progress
                HStack {
                    Text("Weekly Goal")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.orange.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.primary.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    StatsView(userID: "preview-user")
        .modelContainer(for: [UserProfile.self, PrayerDebt.self, DailyLog.self])
        .environment(StatsService(modelContext: ModelContext(try! ModelContainer(for: UserProfile.self, PrayerDebt.self, DailyLog.self)), userID: "preview-user"))
}