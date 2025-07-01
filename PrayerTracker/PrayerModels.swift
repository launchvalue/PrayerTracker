//
//  PrayerModels.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - UserProfile Model

/// Represents the user's profile, including their name, goals, and prayer debt.
@Model
final class UserProfile {
    var name: String = ""
    var dailyGoal: Int = 5
    var streak: Int = 0
    var longestStreak: Int = 0
    
    @Relationship(deleteRule: .cascade, inverse: \PrayerDebt.userProfile) var debt: PrayerDebt?

    var weeklyGoal: Int { dailyGoal * 7 }
    
    init(name: String = "", dailyGoal: Int = 5, streak: Int = 0) {
        self.name = name
        self.dailyGoal = dailyGoal
        self.streak = streak
    }
}

// MARK: - PrayerDebt Model

/// Represents the user's prayer debt.
@Model
final class PrayerDebt {
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
    
    init(fajrOwed: Int = 0, dhuhrOwed: Int = 0, asrOwed: Int = 0, maghribOwed: Int = 0, ishaOwed: Int = 0) {
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
@Model
final class DailyLog {
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
    
    init(date: Date = Date(), fajr: Int = 0, dhuhr: Int = 0, asr: Int = 0, maghrib: Int = 0, isha: Int = 0, notes: String = "") {
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