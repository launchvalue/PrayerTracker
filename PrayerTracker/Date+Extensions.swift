//
//  Date+Extensions.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/26/25.
//

import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}