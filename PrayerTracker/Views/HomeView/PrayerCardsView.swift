import SwiftUI
import SwiftData

struct PrayerCardsView: View {
    let todaysLog: DailyLog
    @Binding var prayerDebt: PrayerDebt
    let userProfile: UserProfile
    let onPrayerUpdate: (String, DailyLog, UserProfile) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            PrayerCardView(
                prayerName: "Fajr",
                prayerOwed: $prayerDebt.fajrOwed,
                prayersCompletedToday: Binding(
                    get: { todaysLog.fajr },
                    set: { todaysLog.fajr = $0 }
                )
            ) { prayerName in
                onPrayerUpdate(prayerName, todaysLog, userProfile)
            }
            
            PrayerCardView(
                prayerName: "Dhuhr",
                prayerOwed: $prayerDebt.dhuhrOwed,
                prayersCompletedToday: Binding(
                    get: { todaysLog.dhuhr },
                    set: { todaysLog.dhuhr = $0 }
                )
            ) { prayerName in
                onPrayerUpdate(prayerName, todaysLog, userProfile)
            }
            
            PrayerCardView(
                prayerName: "Asr",
                prayerOwed: $prayerDebt.asrOwed,
                prayersCompletedToday: Binding(
                    get: { todaysLog.asr },
                    set: { todaysLog.asr = $0 }
                )
            ) { prayerName in
                onPrayerUpdate(prayerName, todaysLog, userProfile)
            }
            
            PrayerCardView(
                prayerName: "Maghrib",
                prayerOwed: $prayerDebt.maghribOwed,
                prayersCompletedToday: Binding(
                    get: { todaysLog.maghrib },
                    set: { todaysLog.maghrib = $0 }
                )
            ) { prayerName in
                onPrayerUpdate(prayerName, todaysLog, userProfile)
            }
            
            PrayerCardView(
                prayerName: "Isha",
                prayerOwed: $prayerDebt.ishaOwed,
                prayersCompletedToday: Binding(
                    get: { todaysLog.isha },
                    set: { todaysLog.isha = $0 }
                )
            ) { prayerName in
                onPrayerUpdate(prayerName, todaysLog, userProfile)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
    }
}

// Preview temporarily disabled due to SwiftData model dependencies
// #Preview {
//     PrayerCardsView(
//         todaysLog: sampleDailyLog,
//         prayerDebt: .constant(samplePrayerDebt),
//         userProfile: sampleUserProfile,
//         onPrayerUpdate: { _, _, _ in }
//     )
// }
