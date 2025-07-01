import SwiftUI
import SwiftData

struct PrayerLogDetailView: View {
    @Bindable var log: DailyLog

    var body: some View {
        NavigationStack {
            Form {
                Section("Prayers") {
                    Stepper("Fajr: \(log.fajr)", value: $log.fajr, in: 0...10)
                    Stepper("Dhuhr: \(log.dhuhr)", value: $log.dhuhr, in: 0...10)
                    Stepper("Asr: \(log.asr)", value: $log.asr, in: 0...10)
                    Stepper("Maghrib: \(log.maghrib)", value: $log.maghrib, in: 0...10)
                    Stepper("Isha: \(log.isha)", value: $log.isha, in: 0...10)
                }

                Section("Notes") {
                    TextField("Notes", text: $log.notes, axis: .vertical)
                        .lineLimit(5...)
                }
            }
            .navigationTitle(log.date.formatted(date: .long, time: .omitted))
        }
    }
}
