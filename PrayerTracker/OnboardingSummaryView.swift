//
//  OnboardingSummaryView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI
import SwiftData

struct OnboardingSummaryView: View {
    @Environment(\.modelContext) private var modelContext

    let name: String
    let gender: String
    let calculationMethod: CalculationMethod
    let startDate: Date
    let endDate: Date
    let bulkYears: Int
    let bulkMonths: Int
    let bulkDays: Int
    let customFajr: Int
    let customDhuhr: Int
    let customAsr: Int
    let customMaghrib: Int
    let customIsha: Int
    let dailyGoal: Int
    let averageCycleLength: Int

    

    private var totalDebt: Int {
        switch calculationMethod {
        case .dateRange:
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: startDate, to: endDate)
            var totalDays = (components.day ?? 0) + 1 // +1 to include the end date
            
            if gender == "Female" && averageCycleLength > 0 {
                let approximateMonths = Double(totalDays) / 30.44 // Using 30.44 days per month for a more accurate average
                let totalMenstrualDays = Int(approximateMonths * Double(averageCycleLength))
                totalDays = max(0, totalDays - totalMenstrualDays)
                print("OnboardingSummaryView: Female calculation - totalDays: \(totalDays), approximateMonths: \(approximateMonths), totalMenstrualDays: \(totalMenstrualDays)")
            }
            print("OnboardingSummaryView: Calculated totalDebt: \(totalDays * 5)")
            return totalDays * 5
        case .bulk:
            return (bulkYears * 354) + (bulkMonths * 30) + (bulkDays * 5)
        case .custom:
            return customFajr + customDhuhr + customAsr + customMaghrib + customIsha
        }
    }

    private var estimatedCompletionDate: String {
        guard dailyGoal > 0 else { return "N/A" }
        let daysToCompletion = Double(totalDebt) / Double(dailyGoal)
        let completionDate = Calendar.current.date(byAdding: .day, value: Int(ceil(daysToCompletion)), to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: completionDate)
    }

    var body: some View {
        VStack {
            Text("Summary")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Form {
                Section(header: Text("Profile")) {
                    Text("Name: \(name)")
                    Text("Gender: \(gender)")
                }

                Section(header: Text("Prayer Debt")) {
                    Text("Calculation Method: \(calculationMethod.rawValue)")
                    Text("Total Debt: \(totalDebt) prayers")
                }

                Section(header: Text("Goal")) {
                    Text("Daily Goal: \(dailyGoal) prayers")
                    Text("Weekly Goal: \(dailyGoal * 7) prayers")
                    Text("Estimated Completion: \(estimatedCompletionDate)")
                }

                Button(action: saveProfile) {
                    Text("Let's Begin")
                }
            }
        }
    }

    private func saveProfile() {
        print("OnboardingSummaryView: saveProfile called.")
        let fajrOwed: Int
        let dhuhrOwed: Int
        let asrOwed: Int
        let maghribOwed: Int
        let ishaOwed: Int

        switch calculationMethod {
        case .dateRange:
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: startDate, to: endDate)
            var debtDays = (components.day ?? 0) + 1 // +1 to include the end date

            if gender == "Female" && averageCycleLength > 0 {
                let approximateMonths = Double(debtDays) / 30.44 // Using 30.44 days per month for a more accurate average
                let totalMenstrualDays = Int(approximateMonths * Double(averageCycleLength))
                debtDays = max(0, debtDays - totalMenstrualDays)
            }
            fajrOwed = debtDays
            dhuhrOwed = debtDays
            asrOwed = debtDays
            maghribOwed = debtDays
            ishaOwed = debtDays
        case .bulk:
            let debt = (bulkYears * 354) + (bulkMonths * 30) + bulkDays
            fajrOwed = debt
            dhuhrOwed = debt
            asrOwed = debt
            maghribOwed = debt
            ishaOwed = debt
        case .custom:
            fajrOwed = customFajr
            dhuhrOwed = customDhuhr
            asrOwed = customAsr
            maghribOwed = customMaghrib
            ishaOwed = customIsha
        }

        let prayerDebt = PrayerDebt(fajrOwed: fajrOwed, dhuhrOwed: dhuhrOwed, asrOwed: asrOwed, maghribOwed: maghribOwed, ishaOwed: ishaOwed)
        let userProfile = UserProfile(name: name, dailyGoal: dailyGoal)
        userProfile.debt = prayerDebt
        modelContext.insert(userProfile)
        print("OnboardingSummaryView: Attempting to save UserProfile: \(userProfile) with PrayerDebt: \(prayerDebt)")
        do {
            try modelContext.save()
            print("OnboardingSummaryView: UserProfile saved successfully!")
        } catch {
            print("OnboardingSummaryView: Failed to save UserProfile: \(error.localizedDescription)")
        }
    }
}