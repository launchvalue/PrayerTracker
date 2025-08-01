
//
//  OnboardingView.swift
//  PrayerTracker
//
//  Created by Developer.
//

import SwiftUI
import SwiftData

enum CalculationMethod: String, CaseIterable {
    case dateRange = "Date Range"
    case bulk = "Bulk Duration"
    case custom = "Custom Entry"
}

struct OnboardingView: View {
    let userID: String
    let onComplete: () -> Void
    @Environment(\.modelContext) private var modelContext
    @State private var currentStep: Int = 0
    @State private var name: String = ""
    @State private var gender: String = "Male"
    @State private var calculationMethod: CalculationMethod = .dateRange
    @State private var startDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
    @State private var endDate: Date = Date()
    @State private var bulkYears: Int = 0
    @State private var bulkMonths: Int = 0
    @State private var bulkDays: Int = 0
    @State private var customFajr: Int = 0
    @State private var customDhuhr: Int = 0
    @State private var customAsr: Int = 0
    @State private var customMaghrib: Int = 0
    @State private var customIsha: Int = 0
    @State private var dailyGoal: Int = 5
    @State private var averageCycleLength: Int = 0
    @State private var profileSaved: Bool = false

    var body: some View {
        TabView(selection: $currentStep) {
            WelcomeView(currentStep: $currentStep)
                .tag(0)
            
            UserInfoView(name: $name, gender: $gender, currentStep: $currentStep)
                .tag(1)
            
            DebtCalculationView(gender: $gender, calculationMethod: $calculationMethod, startDate: $startDate, endDate: $endDate, bulkYears: $bulkYears, bulkMonths: $bulkMonths, bulkDays: $bulkDays, customFajr: $customFajr, customDhuhr: $customDhuhr, customAsr: $customAsr, customMaghrib: $customMaghrib, customIsha: $customIsha, averageCycleLength: $averageCycleLength, currentStep: $currentStep)
                .tag(2)
            
            GoalSelectionView(
                dailyGoal: $dailyGoal,
                currentStep: $currentStep,
                gender: gender,
                calculationMethod: calculationMethod,
                startDate: startDate,
                endDate: endDate,
                bulkYears: bulkYears,
                bulkMonths: bulkMonths,
                bulkDays: bulkDays,
                customFajr: customFajr,
                customDhuhr: customDhuhr,
                customAsr: customAsr,
                customMaghrib: customMaghrib,
                customIsha: customIsha,
                averageCycleLength: averageCycleLength
            )
                .tag(3)
            
            OnboardingSummaryView(
                name: name,
                gender: gender,
                calculationMethod: calculationMethod,
                startDate: startDate,
                endDate: endDate,
                bulkYears: bulkYears,
                bulkMonths: bulkMonths,
                bulkDays: bulkDays,
                customFajr: customFajr,
                customDhuhr: customDhuhr,
                customAsr: customAsr,
                customMaghrib: customMaghrib,
                customIsha: customIsha,
                dailyGoal: dailyGoal,
                averageCycleLength: averageCycleLength,
                currentStep: $currentStep,
                onSave: saveProfile
            )
            .tag(4)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea(.all)
    }
    private func saveProfile() {
        guard !profileSaved else { return } // Prevent multiple saves
        print("OnboardingView: saveProfile called.")
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
            let debt = (bulkYears * 354) + (bulkMonths * 30) + (bulkDays * 5)
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

        let prayerDebt = PrayerDebt(userID: userID, fajrOwed: fajrOwed, dhuhrOwed: dhuhrOwed, asrOwed: asrOwed, maghribOwed: maghribOwed, ishaOwed: ishaOwed)
        let userProfile = UserProfile(userID: userID, name: name, dailyGoal: dailyGoal)
        userProfile.debt = prayerDebt
        modelContext.insert(userProfile)
        print("OnboardingView: Attempting to save UserProfile: \(userProfile) with PrayerDebt: \(prayerDebt) for userID: \(userID)")
        do {
            try modelContext.save()
            print("OnboardingView: UserProfile saved successfully for userID: \(userID)!")
            profileSaved = true // Set flag to true after successful save
            
            // Notify the main app that onboarding is complete
            DispatchQueue.main.async {
                onComplete()
            }
        } catch {
            print("OnboardingView: Failed to save UserProfile for userID \(userID): \(error.localizedDescription)")
        }
    }
}
