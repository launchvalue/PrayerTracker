//
//  Date+Extensions.swift
//  PrayerTracker
//
//  Created by Developer.
//

import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}