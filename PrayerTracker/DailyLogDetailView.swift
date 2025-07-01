import SwiftUI
import SwiftData

struct DailyLogDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var log: DailyLog
    let dailyGoal: Int

    @State private var fajrCount: Int
    @State private var dhuhrCount: Int
    @State private var asrCount: Int
    @State private var maghribCount: Int
    @State private var ishaCount: Int
    @State private var notes: String

    init(log: DailyLog, dailyGoal: Int) {
        self.log = log
        self.dailyGoal = dailyGoal
        _fajrCount = State(initialValue: log.fajr)
        _dhuhrCount = State(initialValue: log.dhuhr)
        _asrCount = State(initialValue: log.asr)
        _maghribCount = State(initialValue: log.maghrib)
        _ishaCount = State(initialValue: log.isha)
        _notes = State(initialValue: log.notes)
    }

    private var isSaveButtonEnabled: Bool {
        fajrCount >= 0 && dhuhrCount >= 0 && asrCount >= 0 && maghribCount >= 0 && ishaCount >= 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Total Prayers Completed:")
                        Spacer()
                        Text("\(fajrCount + dhuhrCount + asrCount + maghribCount + ishaCount) / \(dailyGoal)")
                        if (fajrCount + dhuhrCount + asrCount + maghribCount + ishaCount) >= dailyGoal {
                            Image(systemName: (fajrCount + dhuhrCount + asrCount + maghribCount + ishaCount) > dailyGoal ? "star.fill" : "checkmark.circle.fill")
                                .foregroundColor((fajrCount + dhuhrCount + asrCount + maghribCount + ishaCount) > dailyGoal ? .yellow : .green)
                        }
                    }
                }

                Section("Prayers Completed") {
                    Stepper(value: $fajrCount, in: 0...Int.max) {
                        Text("Fajr: \(fajrCount)")
                    }
                    .accessibilityLabel("Fajr prayers completed: \(fajrCount)")

                    Stepper(value: $dhuhrCount, in: 0...Int.max) {
                        Text("Dhuhr: \(dhuhrCount)")
                    }
                    .accessibilityLabel("Dhuhr prayers completed: \(dhuhrCount)")

                    Stepper(value: $asrCount, in: 0...Int.max) {
                        Text("Asr: \(asrCount)")
                    }
                    .accessibilityLabel("Asr prayers completed: \(asrCount)")

                    Stepper(value: $maghribCount, in: 0...Int.max) {
                        Text("Maghrib: \(maghribCount)")
                    }
                    .accessibilityLabel("Maghrib prayers completed: \(maghribCount)")

                    Stepper(value: $ishaCount, in: 0...Int.max) {
                        Text("Isha: \(ishaCount)")
                    }
                    .accessibilityLabel("Isha prayers completed: \(ishaCount)")
                }

                Section("Notes") {
                    TextField("Add notes for this day", text: $notes, axis: .vertical)
                        .lineLimit(5...)
                }
            }
            .navigationTitle(log.date.formatted(date: .long, time: .omitted))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!isSaveButtonEnabled)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveChanges() {
        log.fajr = fajrCount
        log.dhuhr = dhuhrCount
        log.asr = asrCount
        log.maghrib = maghribCount
        log.isha = ishaCount
        log.notes = notes

        do {
            try modelContext.save()
            print("DailyLog updated successfully!")
        } catch {
            print("Failed to save DailyLog: \(error.localizedDescription)")
        }
        dismiss()
    }
}
