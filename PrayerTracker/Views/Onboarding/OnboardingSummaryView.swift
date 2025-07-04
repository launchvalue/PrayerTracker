
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
            var totalDays = (components.day ?? 0) + 1
            
            if gender == "Female" && averageCycleLength > 0 {
                let approximateMonths = Double(totalDays) / 30.44
                let totalMenstrualDays = Int(approximateMonths * Double(averageCycleLength))
                totalDays = max(0, totalDays - totalMenstrualDays)
            }
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
        VStack(spacing: 30) {
            Text("Ready to Start?")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            ScrollView {
                VStack(spacing: 20) {
                    summaryCard
                    goalCard
                }
            }

            Button(action: onSave) {
                Text("Let's Begin")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(16)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .padding()
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Summary")
                .font(.system(size: 22, weight: .bold, design: .rounded))
            summaryRow(label: "Name", value: name)
            summaryRow(label: "Gender", value: gender)
            summaryRow(label: "Calculation Method", value: calculationMethod.rawValue)
            summaryRow(label: "Total Prayer Debt", value: "\(totalDebt) prayers")
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Goal")
                .font(.system(size: 22, weight: .bold, design: .rounded))
            summaryRow(label: "Daily Goal", value: "\(dailyGoal) prayers")
            summaryRow(label: "Weekly Goal", value: "\(dailyGoal * 7) prayers")
            summaryRow(label: "Estimated Completion", value: estimatedCompletionDate)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .medium, design: .rounded))
        }
    }
}
