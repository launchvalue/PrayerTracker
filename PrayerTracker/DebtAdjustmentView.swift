import SwiftUI
import SwiftData

struct DebtAdjustmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var prayerDebt: PrayerDebt

    @State private var fajrAdjustment: Int
    @State private var dhuhrAdjustment: Int
    @State private var asrAdjustment: Int
    @State private var maghribAdjustment: Int
    @State private var ishaAdjustment: Int

    @State private var showingConfirmationAlert = false

    init(prayerDebt: PrayerDebt) {
        self.prayerDebt = prayerDebt
        _fajrAdjustment = State(initialValue: prayerDebt.fajrOwed)
        _dhuhrAdjustment = State(initialValue: prayerDebt.dhuhrOwed)
        _asrAdjustment = State(initialValue: prayerDebt.asrOwed)
        _maghribAdjustment = State(initialValue: prayerDebt.maghribOwed)
        _ishaAdjustment = State(initialValue: prayerDebt.ishaOwed)
    }

    private var isSaveButtonEnabled: Bool {
        fajrAdjustment >= 0 && dhuhrAdjustment >= 0 && asrAdjustment >= 0 && maghribAdjustment >= 0 && ishaAdjustment >= 0
    }

    var body: some View {
        Form {
            Section(header: Text("Adjust Prayer Counts")) {
                Stepper(value: $fajrAdjustment, in: 0...Int.max) {
                    Text("Fajr: \(fajrAdjustment)")
                }
                .accessibilityLabel("Fajr owed: \(fajrAdjustment)")

                Stepper(value: $dhuhrAdjustment, in: 0...Int.max) {
                    Text("Dhuhr: \(dhuhrAdjustment)")
                }
                .accessibilityLabel("Dhuhr owed: \(dhuhrAdjustment)")

                Stepper(value: $asrAdjustment, in: 0...Int.max) {
                    Text("Asr: \(asrAdjustment)")
                }
                .accessibilityLabel("Asr owed: \(asrAdjustment)")

                Stepper(value: $maghribAdjustment, in: 0...Int.max) {
                    Text("Maghrib: \(maghribAdjustment)")
                }
                .accessibilityLabel("Maghrib owed: \(maghribAdjustment)")

                Stepper(value: $ishaAdjustment, in: 0...Int.max) {
                    Text("Isha: \(ishaAdjustment)")
                }
                .accessibilityLabel("Isha owed: \(ishaAdjustment)")
            }
        }
        .navigationTitle("Adjust Debt")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save Changes") {
                    showingConfirmationAlert = true
                }
                .disabled(!isSaveButtonEnabled)
            }
        }
        .alert("Confirm Debt Adjustment", isPresented: $showingConfirmationAlert) {
            Button("Adjust", role: .destructive) {
                saveChanges()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to adjust your prayer debt to:\nFajr: \(fajrAdjustment)\nDhuhr: \(dhuhrAdjustment)\nAsr: \(asrAdjustment)\nMaghrib: \(maghribAdjustment)\nIsha: \(ishaAdjustment)")
        }
    }

    private func saveChanges() {
        prayerDebt.fajrOwed = fajrAdjustment
        prayerDebt.dhuhrOwed = dhuhrAdjustment
        prayerDebt.asrOwed = asrAdjustment
        prayerDebt.maghribOwed = maghribAdjustment
        prayerDebt.ishaOwed = ishaAdjustment

        // SwiftData automatically saves changes to @Bindable objects
        // No explicit modelContext.save() needed here unless you want to force a save immediately
        // try? modelContext.save()

        dismiss()
    }
}