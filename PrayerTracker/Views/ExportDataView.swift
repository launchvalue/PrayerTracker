//
//  ExportDataView.swift
//  PrayerTracker
//
//  Created by Cascade on 1/25/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ExportDataView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let userProfile: UserProfile
    
    @State private var selectedFormat: ExportFormat = .csv
    @State private var isExporting = false
    @State private var exportError: String?
    @State private var exportedData: String?
    @State private var showingExportResult = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)
                    
                    Text("Export Your Data")
                        .font(.title.bold())
                    
                    Text("Choose a format to export all your prayer tracking data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Format Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Export Format")
                        .font(.headline)
                    
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        FormatSelectionRow(
                            format: format,
                            isSelected: selectedFormat == format,
                            action: { selectedFormat = format }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Export Button
                Button(action: exportData) {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.9)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .medium))
                        }
                        
                        Text(isExporting ? "Exporting..." : "Export Data")
                            .font(.system(size: 17, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.accentColor)
                    )
                }
                .disabled(isExporting)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Export Error", isPresented: .constant(exportError != nil)) {
                Button("OK") {
                    exportError = nil
                }
            } message: {
                if let error = exportError {
                    Text(error)
                }
            }
            .sheet(isPresented: $showingExportResult) {
                ExportResultView(data: exportedData ?? "", format: selectedFormat)
            }
        }
    }
    
    private func exportData() {
        isExporting = true
        exportError = nil
        
        Task {
            do {
                let result = try await performExport(format: selectedFormat)
                
                await MainActor.run {
                    exportedData = result
                    showingExportResult = true
                    isExporting = false
                }
            } catch {
                await MainActor.run {
                    exportError = "Failed to export data: \(error.localizedDescription)"
                    isExporting = false
                }
            }
        }
    }
    
    private func performExport(format: ExportFormat) async throws -> String {
        // Fetch data from SwiftData
        let userID = userProfile.userID
        
        let prayerDebtDescriptor = FetchDescriptor<PrayerDebt>(
            predicate: #Predicate<PrayerDebt> { debt in
                debt.userID == userID
            }
        )
        
        let dailyLogsDescriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate<DailyLog> { log in
                log.userID == userID
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let prayerDebt = try modelContext.fetch(prayerDebtDescriptor).first
        let dailyLogs = try modelContext.fetch(dailyLogsDescriptor)
        
        switch format {
        case .csv:
            return generateCSV(userProfile: userProfile, prayerDebt: prayerDebt, dailyLogs: dailyLogs)
        case .json:
            return generateJSON(userProfile: userProfile, prayerDebt: prayerDebt, dailyLogs: dailyLogs)
        case .pdf:
            return "PDF export coming soon!"
        }
    }
    
    private func generateCSV(userProfile: UserProfile, prayerDebt: PrayerDebt?, dailyLogs: [DailyLog]) -> String {
        var csv = ""
        
        // User Profile Section
        csv += "User Profile\n"
        csv += "Name,Daily Goal,Current Streak,Longest Streak\n"
        csv += "\"\(userProfile.name)\",\(userProfile.dailyGoal),\(userProfile.streak),\(userProfile.longestStreak)\n\n"
        
        // Prayer Debt Section
        if let debt = prayerDebt {
            csv += "Prayer Debt\n"
            csv += "Prayer Type,Currently Owed,Initially Owed,Completed\n"
            csv += "Fajr,\(debt.fajrOwed),\(debt.initialFajrOwed),\(debt.initialFajrOwed - debt.fajrOwed)\n"
            csv += "Dhuhr,\(debt.dhuhrOwed),\(debt.initialDhuhrOwed),\(debt.initialDhuhrOwed - debt.dhuhrOwed)\n"
            csv += "Asr,\(debt.asrOwed),\(debt.initialAsrOwed),\(debt.initialAsrOwed - debt.asrOwed)\n"
            csv += "Maghrib,\(debt.maghribOwed),\(debt.initialMaghribOwed),\(debt.initialMaghribOwed - debt.maghribOwed)\n"
            csv += "Isha,\(debt.ishaOwed),\(debt.initialIshaOwed),\(debt.initialIshaOwed - debt.ishaOwed)\n\n"
        }
        
        // Daily Logs Section
        csv += "Daily Prayer Logs\n"
        csv += "Date,Fajr,Dhuhr,Asr,Maghrib,Isha,Total,Notes\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        for log in dailyLogs {
            let dateString = dateFormatter.string(from: log.date)
            let notes = log.notes.replacingOccurrences(of: "\"", with: "\"\"")
            csv += "\"\(dateString)\",\(log.fajr),\(log.dhuhr),\(log.asr),\(log.maghrib),\(log.isha),\(log.prayersCompleted),\"\(notes)\"\n"
        }
        
        return csv
    }
    
    private func generateJSON(userProfile: UserProfile, prayerDebt: PrayerDebt?, dailyLogs: [DailyLog]) -> String {
        let exportDict: [String: Any] = [
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "appVersion": "1.0.0",
            "userProfile": [
                "name": userProfile.name,
                "dailyGoal": userProfile.dailyGoal,
                "streak": userProfile.streak,
                "longestStreak": userProfile.longestStreak
            ],
            "prayerDebt": prayerDebt != nil ? [
                "fajrOwed": prayerDebt!.fajrOwed,
                "dhuhrOwed": prayerDebt!.dhuhrOwed,
                "asrOwed": prayerDebt!.asrOwed,
                "maghribOwed": prayerDebt!.maghribOwed,
                "ishaOwed": prayerDebt!.ishaOwed,
                "totalOwed": prayerDebt!.fajrOwed + prayerDebt!.dhuhrOwed + prayerDebt!.asrOwed + prayerDebt!.maghribOwed + prayerDebt!.ishaOwed
            ] : nil,
            "dailyLogs": dailyLogs.map { log in
                [
                    "date": ISO8601DateFormatter().string(from: log.date),
                    "fajr": log.fajr,
                    "dhuhr": log.dhuhr,
                    "asr": log.asr,
                    "maghrib": log.maghrib,
                    "isha": log.isha,
                    "total": log.prayersCompleted,
                    "notes": log.notes
                ]
            }
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportDict, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8) ?? "Error generating JSON"
        } catch {
            return "Error generating JSON: \(error.localizedDescription)"
        }
    }
}

// MARK: - Export Format Enum

enum ExportFormat: String, CaseIterable {
    case csv = "csv"
    case json = "json"
    case pdf = "pdf"
    
    var displayName: String {
        switch self {
        case .csv: return "CSV (Spreadsheet)"
        case .json: return "JSON (Structured Data)"
        case .pdf: return "PDF (Report)"
        }
    }
    
    var description: String {
        switch self {
        case .csv: return "Compatible with Excel, Google Sheets, and other spreadsheet applications"
        case .json: return "Technical format for developers and advanced users"
        case .pdf: return "Human-readable formatted report for printing or viewing"
        }
    }
    
    var icon: String {
        switch self {
        case .csv: return "tablecells"
        case .json: return "curlybraces"
        case .pdf: return "doc.richtext"
        }
    }
}

// MARK: - Format Selection Row

struct FormatSelectionRow: View {
    let format: ExportFormat
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: format.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.accentColor)
                    .frame(width: 32)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(format.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(format.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .accentColor : .secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Export Result View

struct ExportResultView: View {
    let data: String
    let format: ExportFormat
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    Text(data)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                }
                
                Button("Copy to Clipboard") {
                    UIPasteboard.general.string = data
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("\(format.displayName) Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var sampleProfile: UserProfile = {
        let profile = UserProfile()
        profile.name = "John Doe"
        profile.dailyGoal = 10
        profile.userID = "sample_user"
        return profile
    }()
    
    ExportDataView(userProfile: sampleProfile)
}
