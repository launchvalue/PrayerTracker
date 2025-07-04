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
        VStack(spacing: 30) {
            Text("Calculate Your Prayer Debt")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Picker("Calculation Method", selection: $calculationMethod) {
                ForEach(CalculationMethod.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

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
            .scrollContentBackground(.hidden)
        }
        .padding()
    }

    private var dateRangeSection: some View {
        Section(header: Text("Date Range")) {
            DatePicker("Start Date", selection: $startDate, in: ...endDate, displayedComponents: .date)
            DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
            if gender == "Female" {
                femaleSpecificSection
            }
        }
    }

    private var femaleSpecificSection: some View {
        Section(header: Text("Menstrual Cycle Information")) {
            Stepper(value: $averageCycleLength, in: 0...30) {
                Text("Average Cycle Length: \(averageCycleLength) days")
            }
        }
    }

    private var bulkDurationSection: some View {
        Section(header: Text("Bulk Duration")) {
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
    }

    private var customEntrySection: some View {
        Section(header: Text("Custom Entry")) {
            stepperRow(label: "Fajr", binding: $customFajr)
            stepperRow(label: "Dhuhr", binding: $customDhuhr)
            stepperRow(label: "Asr", binding: $customAsr)
            stepperRow(label: "Maghrib", binding: $customMaghrib)
            stepperRow(label: "Isha", binding: $customIsha)
        }
    }

    private func stepperRow(label: String, binding: Binding<Int>) -> some View {
        Stepper(value: binding, in: 0...10000) { 
            Text("\(label): \(binding.wrappedValue)")
        }
    }
}