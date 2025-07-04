//
//  OnboardingSummaryView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI

struct OnboardingSummaryView: View {
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
    let onSave: () -> Void

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
        ZStack {
            // Background with a subtle gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Ready to Start?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        summaryCard
                        goalCard
                    }
                    .padding()
                }

                Button(action: onSave) {
                    Text("Let's Begin")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Summary")
                .font(.title2)
                .fontWeight(.semibold)

            summaryRow(label: "Name", value: name)
            summaryRow(label: "Gender", value: gender)
            summaryRow(label: "Calculation Method", value: calculationMethod.rawValue)
            summaryRow(label: "Total Prayer Debt", value: "\(totalDebt) prayers")
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Goal")
                .font(.title2)
                .fontWeight(.semibold)

            summaryRow(label: "Daily Goal", value: "\(dailyGoal) prayers")
            summaryRow(label: "Weekly Goal", value: "\(dailyGoal * 7) prayers")
            summaryRow(label: "Estimated Completion", value: estimatedCompletionDate)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}