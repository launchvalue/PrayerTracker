//
//  OnboardingView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI

enum CalculationMethod: String, CaseIterable {
    case dateRange = "Date Range"
    case bulk = "Bulk Duration"
    case custom = "Custom Entry"
}

struct OnboardingView: View {
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

    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $currentStep) {
                    // New Welcome Screen
                    WelcomeView(currentStep: $currentStep)
                        .tag(0)

                    UserInfoView(name: $name, gender: $gender)
                        .tag(1)
                    DebtCalculationView(gender: $gender, calculationMethod: $calculationMethod, startDate: $startDate, endDate: $endDate, bulkYears: $bulkYears, bulkMonths: $bulkMonths, bulkDays: $bulkDays, customFajr: $customFajr, customDhuhr: $customDhuhr, customAsr: $customAsr, customMaghrib: $customMaghrib, customIsha: $customIsha, averageCycleLength: $averageCycleLength)
                        .tag(2)
                    GoalSelectionView(dailyGoal: $dailyGoal)
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
                        averageCycleLength: averageCycleLength
                    )
                    .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .gesture(DragGesture())

                // Navigation buttons (only for subsequent steps)
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                    }

                    Spacer()

                    if currentStep < 4 {
                        Button("Continue") {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    } else {
                        // This button will be handled by OnboardingSummaryView
                        EmptyView()
                    }
                }
                .padding()
            }
        }
    }
}

struct WelcomeView: View {
    @Binding var currentStep: Int

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "hand.raised.fill") // Placeholder for illustration
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.accentColor)

            Text("Welcome to Qada Prayer Companion")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Your personal tool to track and manage missed prayers, helping you fulfill your spiritual obligations with ease and confidence.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundStyle(.secondary)

            Spacer()

            Button("Get Started") {
                withAnimation {
                    currentStep = 1 // Navigate to UserInfoView (gender selection)
                }
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(15)
            .padding(.horizontal)

            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}