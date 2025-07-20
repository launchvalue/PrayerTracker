//
//  PrayerModels.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Islamic Calendar Type Enum

enum IslamicCalendarType: String, CaseIterable {
    case ummAlQura = "islamicUmmAlQura"
    case civil = "islamic"
    case tabular = "islamicTabular"
    
    var displayName: String {
        switch self {
        case .ummAlQura:
            return "Umm al-Qura (Saudi Arabia)"
        case .civil:
            return "Islamic Civil Calendar"
        case .tabular:
            return "Islamic Tabular Calendar"
        }
    }
    
    var calendarIdentifier: Calendar.Identifier {
        switch self {
        case .ummAlQura:
            return .islamicUmmAlQura
        case .civil:
            return .islamic
        case .tabular:
            return .islamicTabular
        }
    }
}

// MARK: - UserProfile Model

/// Represents the user's profile, including their name, goals, and prayer debt.
@Model @Observable
final class UserProfile {
    var userID: String = "" // Google Sign-In user ID for data isolation
    var name: String = ""
    var dailyGoal: Int = 5
    var streak: Int = 0
    var longestStreak: Int = 0
    var lastStreakUpdate: Date?
    var lastCompletedDate: Date?
    private var islamicCalendarTypeRaw: String = "islamicUmmAlQura" // Default to Umm al-Qura
    
    /// User's preferred Islamic calendar type with type safety
    var islamicCalendarType: IslamicCalendarType {
        get {
            return IslamicCalendarType(rawValue: islamicCalendarTypeRaw) ?? .ummAlQura
        }
        set {
            islamicCalendarTypeRaw = newValue.rawValue
        }
    }
    
    @Relationship(deleteRule: .cascade, inverse: \PrayerDebt.userProfile) var debt: PrayerDebt?

    var weeklyGoal: Int { dailyGoal * 7 }
    
    init(userID: String = "", name: String = "", dailyGoal: Int = 5, streak: Int = 0) {
        self.userID = userID
        self.name = name
        self.dailyGoal = dailyGoal
        self.streak = streak
        self.lastStreakUpdate = nil
        self.lastCompletedDate = nil
    }
}

// MARK: - PrayerDebt Model

/// Represents the user's prayer debt.
@Model @Observable
final class PrayerDebt {
    var userID: String = "" // Google Sign-In user ID for data isolation
    var fajrOwed: Int = 0
    var initialFajrOwed: Int = 0
    var dhuhrOwed: Int = 0
    var initialDhuhrOwed: Int = 0
    var asrOwed: Int = 0
    var initialAsrOwed: Int = 0
    var maghribOwed: Int = 0
    var initialMaghribOwed: Int = 0
    var ishaOwed: Int = 0
    var initialIshaOwed: Int = 0
    var userProfile: UserProfile?
    
    var totalInitialDebt: Int {
        initialFajrOwed + initialDhuhrOwed + initialAsrOwed + initialMaghribOwed + initialIshaOwed
    }
    
    init(userID: String = "", fajrOwed: Int = 0, dhuhrOwed: Int = 0, asrOwed: Int = 0, maghribOwed: Int = 0, ishaOwed: Int = 0) {
        self.userID = userID
        self.fajrOwed = fajrOwed
        self.initialFajrOwed = fajrOwed
        self.dhuhrOwed = dhuhrOwed
        self.initialDhuhrOwed = dhuhrOwed
        self.asrOwed = asrOwed
        self.initialAsrOwed = asrOwed
        self.maghribOwed = maghribOwed
        self.initialMaghribOwed = maghribOwed
        self.ishaOwed = ishaOwed
        self.initialIshaOwed = ishaOwed
    }
}

// MARK: - DailyLog Model

/// Represents a daily log of completed prayers.
@Model @Observable
final class DailyLog {
    var userID: String = "" // Google Sign-In user ID for data isolation
    var date: Date = Date()
    var fajr: Int = 0
    var dhuhr: Int = 0
    var asr: Int = 0
    var maghrib: Int = 0
    var isha: Int = 0
    var notes: String = ""

    var prayersCompleted: Int {
        fajr + dhuhr + asr + maghrib + isha
    }

    func dotCount(goal: Int) -> Int {
        guard prayersCompleted >= goal else { return 0 }
        return prayersCompleted > goal ? 2 : 1
    }
    
    var dateOnly: Date {
        Calendar.current.startOfDay(for: date)
    }
    
    init(userID: String = "", date: Date = Date(), fajr: Int = 0, dhuhr: Int = 0, asr: Int = 0, maghrib: Int = 0, isha: Int = 0, notes: String = "") {
        self.userID = userID
        self.date = date
        self.fajr = fajr
        self.dhuhr = dhuhr
        self.asr = asr
        self.maghrib = maghrib
        self.isha = isha
        self.notes = notes
    }
}

// MARK: - PrayerType Enum

enum PrayerType: String, CaseIterable {
    case fajr = "Fajr"
    case dhuhr = "Dhuhr"
    case asr = "Asr"
    case maghrib = "Maghrib"
    case isha = "Isha"

    var color: Color {
        switch self {
        case .fajr: .green
        case .dhuhr: .blue
        case .asr: .orange
        case .maghrib: .purple
        case .isha: .indigo
        }
    }
}