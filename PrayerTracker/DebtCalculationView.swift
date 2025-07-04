//
//  DebtCalculationView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI

struct DebtCalculationView: View {
    @Binding var gender: String
    @Binding var calculationMethod: CalculationMethod
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var bulkYears: Int
    @Binding var bulkMonths: Int
    @Binding var bulkDays: Int
    @Binding var customFajr: Int
    @Binding var customDhuhr: Int
    @Binding var customAsr: Int
    @Binding var customMaghrib: Int
    @Binding var customIsha: Int
    @Binding var averageCycleLength: Int

    var body: some View {
        ZStack {
            // Background with a subtle gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Calculate Your Prayer Debt")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Picker("Calculation Method", selection: $calculationMethod) {
                    ForEach(CalculationMethod.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .background(.ultraThinMaterial)
                .cornerRadius(12)

                Form {
                    switch calculationMethod {
                    case .dateRange:
                        dateRangeSection
                    case .bulk:
                        bulkDurationSection
                    case .custom:
                        customEntrySection
                    }
                }
                .scrollContentBackground(.hidden) // Make form background transparent
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private var dateRangeSection: some View {
        Section(
            header: Text("Date Range")
                .font(.headline)
                .foregroundColor(.primary)
        ) {
            DatePicker(
                "Start Date",
                selection: $startDate,
                in: ...endDate,
                displayedComponents: .date
            )
            DatePicker(
                "End Date",
                selection: $endDate,
                in: startDate...,
                displayedComponents: .date
            )
            
            if gender == "Female" {
                femaleSpecificSection
            }
        }
        .listRowBackground(Color.white.opacity(0.5))
    }

    private var femaleSpecificSection: some View {
        Section(header: Text("Menstrual Cycle Information")) {
            HStack {
                Text("Average Cycle Length")
                Spacer()
                TextField("Days", value: $averageCycleLength, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            DisclosureGroup("Need help?") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("This helps us calculate your Qada prayers more accurately by excluding days when prayers are not required.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("**Typical Ranges:** Light flow: 3-4 days, Average flow: 5-7 days, Heavy flow: 7-10 days.")
                    Text("**Not sure?** Use 6 days as a conservative estimate.")
                    Text("**Irregular cycles?** Consider consulting a scholar.")
                }
                .font(.caption)
            }
        }
        .listRowBackground(Color.white.opacity(0.5))
    }

    private var bulkDurationSection: some View {
        Section(
            header: Text("Bulk Duration")
                .font(.headline)
                .foregroundColor(.primary)
        ) {
            Stepper(value: $bulkYears, in: 0...100) {
                Text("\(bulkYears) Years")
            }
            Stepper(value: $bulkMonths, in: 0...11) {
                Text("\(bulkMonths) Months")
            }
            Stepper(value: $bulkDays, in: 0...30) {
                Text("\(bulkDays) Days")
            }
        }
        .listRowBackground(Color.white.opacity(0.5))
    }

    private var customEntrySection: some View {
        Section(
            header: Text("Custom Entry")
                .font(.headline)
                .foregroundColor(.primary)
        ) {
            stepperRow(label: "Fajr", binding: $customFajr)
            stepperRow(label: "Dhuhr", binding: $customDhuhr)
            stepperRow(label: "Asr", binding: $customAsr)
            stepperRow(label: "Maghrib", binding: $customMaghrib)
            stepperRow(label: "Isha", binding: $customIsha)
        }
        .listRowBackground(Color.white.opacity(0.5))
    }

    private func stepperRow(label: String, binding: Binding<Int>) -> some View {
        Stepper(value: binding, in: 0...10000) { // Assuming a reasonable upper limit
            Text("\(label): \(binding.wrappedValue)")
        }
    }
}
