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
    @Binding var currentStep: Int
    
    @State private var showContent = false
    @State private var showDatePicker = false
    
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
            return (bulkYears * 354 * 5) + (bulkMonths * 30 * 5) + (bulkDays * 5)
        case .custom:
            return customFajr + customDhuhr + customAsr + customMaghrib + customIsha
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        Spacer(minLength: 12)
                        
                        // Progress Indicator
                        HStack(spacing: 8) {
                            ForEach(0..<5) { index in
                                Circle()
                                    .fill(index == 2 ? Color.accentColor : Color.accentColor.opacity(0.2))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(index == 2 ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3), value: index == 2)
                            }
                        }
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                        
                        // Title Section
                        VStack(spacing: 6) {
                            Text("Calculate Your Prayer Debt")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text("Choose the method that works best for you")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
                        
                        Spacer(minLength: 12)
                    }
                    .frame(minHeight: geometry.size.height * 0.25)
                    
                    // Main Content
                    VStack(spacing: 24) {
                        // Method Selection Cards
                        VStack(spacing: 20) {
                                MethodCard(
                                    method: .dateRange,
                                    title: "Date Range",
                                    description: "Select the period when you missed prayers",
                                    icon: "calendar.badge.clock",
                                    isSelected: calculationMethod == .dateRange
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        calculationMethod = .dateRange
                                    }
                                }
                                
                                MethodCard(
                                    method: .bulk,
                                    title: "Bulk Duration",
                                    description: "Estimate based on years, months, and days",
                                    icon: "clock.badge.questionmark",
                                    isSelected: calculationMethod == .bulk
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        calculationMethod = .bulk
                                    }
                                }
                                
                                MethodCard(
                                    method: .custom,
                                    title: "Custom Entry",
                                    description: "Enter exact numbers for each prayer",
                                    icon: "slider.horizontal.3",
                                    isSelected: calculationMethod == .custom
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        calculationMethod = .custom
                                    }
                                }
                        }
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(0.6), value: showContent)
                        
                        // Method-specific Content
                        VStack(spacing: 24) {
                            switch calculationMethod {
                            case .dateRange:
                                dateRangeContent
                            case .bulk:
                                bulkDurationContent
                            case .custom:
                                customEntryContent
                            }
                        }
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(0.8), value: showContent)
                        
                        // Total Debt Display
                        if totalDebt > 0 {
                            VStack(spacing: 16) {
                                Text("Estimated Total Debt")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [Color.accentColor.opacity(0.1), Color.accentColor.opacity(0.2)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .frame(height: 80)
                                    
                                    VStack(spacing: 4) {
                                        Text("\(totalDebt)")
                                            .font(.system(size: 32, weight: .bold, design: .rounded))
                                            .foregroundColor(.accentColor)
                                        
                                        Text("total prayers")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .opacity(showContent ? 1.0 : 0.0)
                            .offset(y: showContent ? 0 : 30)
                            .animation(.easeOut(duration: 0.6).delay(1.0), value: showContent)
                        }
                        
                        // Navigation Buttons
                        SimpleNavigationButtons(
                            backAction: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStep -= 1
                                }
                            },
                            continueAction: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStep += 1
                                }
                            },
                            canGoBack: true,
                            canContinue: true
                        )
                        .padding(.top, 32)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6).delay(1.0), value: showContent)
                        
                        // Bottom spacing
                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            showContent = true
        }
    }
    
    // MARK: - Method-specific Content Views
    
    private var dateRangeContent: some View {
        VStack(spacing: 20) {
            Text("Select the time period when you missed prayers")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                DateSelectionRow(title: "Start Date", date: $startDate, maxDate: endDate)
                DateSelectionRow(title: "End Date", date: $endDate, minDate: startDate)
                
                if gender == "Female" {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.accentColor)
                            
                            Text("Menstrual Cycle Adjustment")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Average cycle length: \(averageCycleLength) days")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            
                            Slider(value: Binding(
                                get: { Double(averageCycleLength) },
                                set: { averageCycleLength = Int($0) }
                            ), in: 0...15, step: 1)
                                .accentColor(.accentColor)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.accentColor.opacity(0.05))
                        )
                    }
                }
            }
        }
    }
    
    private var bulkDurationContent: some View {
        VStack(spacing: 20) {
            Text("Estimate the duration when you missed prayers")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                StepperRow(title: "Years", value: $bulkYears, range: 0...50, icon: "calendar")
                StepperRow(title: "Months", value: $bulkMonths, range: 0...11, icon: "calendar.badge.clock")
                StepperRow(title: "Days", value: $bulkDays, range: 0...30, icon: "clock")
            }
        }
    }
    
    private var customEntryContent: some View {
        VStack(spacing: 20) {
            Text("Enter the exact number of missed prayers for each type")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                PrayerStepperRow(title: "Fajr", value: $customFajr, color: .blue)
                PrayerStepperRow(title: "Dhuhr", value: $customDhuhr, color: .orange)
                PrayerStepperRow(title: "Asr", value: $customAsr, color: .yellow)
                PrayerStepperRow(title: "Maghrib", value: $customMaghrib, color: .pink)
                PrayerStepperRow(title: "Isha", value: $customIsha, color: .purple)
            }
        }
    }
}

// MARK: - Supporting Components

struct MethodCard: View {
    let method: CalculationMethod
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .accentColor : .secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.primary.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DateSelectionRow: View {
    let title: String
    @Binding var date: Date
    var minDate: Date? = nil
    var maxDate: Date? = nil
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            DatePicker(
                title,
                selection: $date,
                in: (minDate ?? Date.distantPast)...(maxDate ?? Date.distantFuture),
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
    }
}

struct StepperRow: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("\(value) \(title.lowercased())")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    if value > range.lowerBound {
                        withAnimation(.spring(response: 0.2)) {
                            value -= 1
                        }
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(value > range.lowerBound ? .accentColor : .secondary)
                }
                .disabled(value <= range.lowerBound)
                
                Button(action: {
                    if value < range.upperBound {
                        withAnimation(.spring(response: 0.2)) {
                            value += 1
                        }
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(value < range.upperBound ? .accentColor : .secondary)
                }
                .disabled(value >= range.upperBound)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
    }
}

struct PrayerStepperRow: View {
    let title: String
    @Binding var value: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("\(value) prayers")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    if value > 0 {
                        withAnimation(.spring(response: 0.2)) {
                            value = max(0, value - 10)
                        }
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(value > 0 ? .accentColor : .secondary)
                }
                .disabled(value <= 0)
                
                Button(action: {
                    withAnimation(.spring(response: 0.2)) {
                        value += 10
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.accentColor)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
    }
}