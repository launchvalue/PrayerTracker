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
        VStack {
            Text("Calculate Your Prayer Debt")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Picker("Calculation Method", selection: $calculationMethod) {
                ForEach(CalculationMethod.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            Form {
                switch calculationMethod {
                case .dateRange:
                    DatePicker(
                        "Start Date",
                        selection: $startDate,
                        in: ...endDate,
                        displayedComponents: .date
                    )
                    .onChange(of: startDate) {
                        print("DebtCalculationView: Start Date changed to \(startDate)")
                    }
                    DatePicker(
                        "End Date",
                        selection: $endDate,
                        in: startDate...,
                        displayedComponents: .date
                    )
                    .onChange(of: endDate) {
                        print("DebtCalculationView: End Date changed to \(endDate)")
                    }
                    
                    if gender == "Female" && calculationMethod == .dateRange {
                        Section(header: Text("Menstrual Cycle Information")) {
                            TextField("Average Cycle Length (days)", value: $averageCycleLength, format: .number)
                                .keyboardType(.numberPad)
                            Text("ℹ️ This helps us calculate your Qada prayers more accurately by excluding days when prayers are not required.")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            DisclosureGroup("❓ Need help determining this?") {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("**Typical Ranges:**")
                                    Text("• Light flow: 3-4 days")
                                    Text("• Average flow: 5-7 days")
                                    Text("• Heavy flow: 7-10 days")
                                    Text("")
                                    Text("**🤔 Not sure?** Use 6 days as a conservative estimate.")
                                    Text("")
                                    Text("**⚠️ Very irregular cycles?** Consider consulting a scholar for personalized guidance.")
                                    Text("")
                                    Text("📚 Learn about Islamic basis for estimation principles")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .onTapGesture {
                                            // TODO: Navigate to EducationView with specific section highlighted
                                        }
                                }
                                .font(.caption)
                            }
                        }
                    }
                case .bulk:
                    Section(header: Text("Bulk Duration")) {
                        TextField("Years", value: $bulkYears, format: .number)
                            .keyboardType(.numberPad)
                        TextField("Months", value: $bulkMonths, format: .number)
                            .keyboardType(.numberPad)
                        TextField("Days", value: $bulkDays, format: .number)
                            .keyboardType(.numberPad)
                    }
                case .custom:
                    Section(header: Text("Custom Entry")) {
                        TextField("Fajr", value: $customFajr, format: .number)
                            .keyboardType(.numberPad)
                        TextField("Dhuhr", value: $customDhuhr, format: .number)
                            .keyboardType(.numberPad)
                        TextField("Asr", value: $customAsr, format: .number)
                            .keyboardType(.numberPad)
                        TextField("Maghrib", value: $customMaghrib, format: .number)
                            .keyboardType(.numberPad)
                        TextField("Isha", value: $customIsha, format: .number)
                            .keyboardType(.numberPad)
                    }
                }
            }
        }
    }
}
