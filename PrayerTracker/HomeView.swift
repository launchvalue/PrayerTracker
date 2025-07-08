import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    let userProfile: UserProfile
    @Binding var prayerDebt: PrayerDebt

    @Query(sort: \DailyLog.date, order: .reverse) private var dailyLogs: [DailyLog]

    private var todaysLog: DailyLog? {
        if let log = dailyLogs.first(where: { Calendar.current.isDateInToday($0.date) }) {
            return log
        } else {
            let newLog = DailyLog(date: Date().startOfDay)
            modelContext.insert(newLog)
            do {
                try modelContext.save()
                print("DailyLog created successfully in HomeView!")
            } catch {
                print("Failed to create DailyLog in HomeView: \(error.localizedDescription)")
            }
            return newLog
        }
    }

    private var totalRemaining: Int {
        prayerDebt.fajrOwed + prayerDebt.dhuhrOwed + prayerDebt.asrOwed + prayerDebt.maghribOwed + prayerDebt.ishaOwed
    }

    private var prayersMadeUpThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())!.start
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())!.end

        return dailyLogs.filter { log in
            log.dateOnly >= startOfWeek && log.dateOnly < endOfWeek
        }.reduce(0) { $0 + $1.prayersCompleted }
    }
    
    private var currentWeekLogs: [DailyLog] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())!.start
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())!.end
        
        return dailyLogs.filter { log in
            log.dateOnly >= startOfWeek && log.dateOnly < endOfWeek
        }
    }

    private var progress: Double {
        guard userProfile.weeklyGoal > 0 else { return 0 }
        return Double(prayersMadeUpThisWeek) / Double(userProfile.weeklyGoal)
    }

    

    private func updatePrayerStatus(prayerName: String, log: DailyLog, profile: UserProfile) {
        switch prayerName {
        case "Fajr":
            if prayerDebt.fajrOwed > 0 {
                log.fajr += 1
                prayerDebt.fajrOwed -= 1
                profile.streak += 1
            }
        case "Dhuhr":
            if prayerDebt.dhuhrOwed > 0 {
                log.dhuhr += 1
                prayerDebt.dhuhrOwed -= 1
                profile.streak += 1
            }
        case "Asr":
            if prayerDebt.asrOwed > 0 {
                log.asr += 1
                prayerDebt.asrOwed -= 1
                profile.streak += 1
            }
        case "Maghrib":
            if prayerDebt.maghribOwed > 0 {
                log.maghrib += 1
                prayerDebt.maghribOwed -= 1
                profile.streak += 1
            }
        case "Isha":
            if prayerDebt.ishaOwed > 0 {
                log.isha += 1
                prayerDebt.ishaOwed -= 1
                profile.streak += 1
            }
        default:
            break
        }
        do {
            try modelContext.save()
            print("Prayer status updated and debt adjusted.")
        } catch {
            print("Failed to update prayer status or debt: \(error.localizedDescription)")
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) { // Increased spacing for better visual separation
                // Custom Header: Dashboard Title and Greeting
                VStack(alignment: .leading, spacing: 5) {
                    Text("Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Assalamu Alaykum, \(userProfile.name)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 20) // Adjusted top padding for overall screen

                // Weekly Progress Capsules
                WeeklyProgressCapsuleView(
                    dailyGoal: userProfile.dailyGoal,
                    weeklyLogs: currentWeekLogs
                )
                .padding(.horizontal)

                // Today's Log Section
                VStack(alignment: .leading, spacing: 15) { // Added VStack for Today's Log section
                    HStack {
                        Text("Today's Log")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(Date(), format: .dateTime.day().month().year())
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(hijriDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal) // Apply horizontal padding to the HStack

                    if let todayLog = todaysLog {
                        VStack(spacing: 10) {
                            PrayerCardView(prayerName: "Fajr", prayerOwed: $prayerDebt.fajrOwed, prayersCompletedToday: Binding(get: { todayLog.fajr }, set: { todayLog.fajr = $0 })) { prayerName in
                                updatePrayerStatus(prayerName: prayerName, log: todayLog, profile: userProfile)
                            }
                            PrayerCardView(prayerName: "Dhuhr", prayerOwed: $prayerDebt.dhuhrOwed, prayersCompletedToday: Binding(get: { todayLog.dhuhr }, set: { todayLog.dhuhr = $0 })) { prayerName in
                                updatePrayerStatus(prayerName: prayerName, log: todayLog, profile: userProfile)
                            }
                            PrayerCardView(prayerName: "Asr", prayerOwed: $prayerDebt.asrOwed, prayersCompletedToday: Binding(get: { todayLog.asr }, set: { todayLog.asr = $0 })) { prayerName in
                                updatePrayerStatus(prayerName: prayerName, log: todayLog, profile: userProfile)
                            }
                            PrayerCardView(prayerName: "Maghrib", prayerOwed: $prayerDebt.maghribOwed, prayersCompletedToday: Binding(get: { todayLog.maghrib }, set: { todayLog.maghrib = $0 })) { prayerName in
                                updatePrayerStatus(prayerName: prayerName, log: todayLog, profile: userProfile)
                            }
                            PrayerCardView(prayerName: "Isha", prayerOwed: $prayerDebt.ishaOwed, prayersCompletedToday: Binding(get: { todayLog.isha }, set: { todayLog.isha = $0 })) { prayerName in
                                updatePrayerStatus(prayerName: prayerName, log: todayLog, profile: userProfile)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical)
                    } else {
                        Text("Error: Could not load or create daily log.")
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20) // Add padding to the bottom of the entire VStack
            }
            .padding(.horizontal, 16) // Apply horizontal padding to the main VStack
        }
        .navigationBarHidden(true) // Hide default navigation bar
    }

    private var hijriDate: String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .islamicUmmAlQura)
        formatter.dateFormat = "d MMMM yyyy G"
        return formatter.string(from: date)
    }
}