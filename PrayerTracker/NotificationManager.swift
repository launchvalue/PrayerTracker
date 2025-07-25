import Foundation
import UserNotifications
import SwiftUI

@Observable
class NotificationManager {
    static let shared = NotificationManager()
    
    private let userDefaults = UserDefaults.standard
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // Published properties for settings UI
    var dailyReminderEnabled: Bool {
        didSet {
            userDefaults.set(dailyReminderEnabled, forKey: "dailyReminderEnabled")
            updateNotifications()
        }
    }
    
    var reminderTime: Date {
        didSet {
            userDefaults.set(reminderTime, forKey: "reminderTime")
            updateNotifications()
        }
    }
    
    private init() {
        // Load saved preferences
        self.dailyReminderEnabled = userDefaults.bool(forKey: "dailyReminderEnabled")
        
        // Load saved time or default to 4:37 PM (as shown in the screenshot)
        if let savedTimeData = userDefaults.data(forKey: "reminderTime"),
           let savedTime = try? JSONDecoder().decode(Date.self, from: savedTimeData) {
            self.reminderTime = savedTime
        } else {
            // Default to 4:37 PM
            let calendar = Calendar.current
            let components = DateComponents(hour: 16, minute: 37)
            self.reminderTime = calendar.date(from: components) ?? Date()
        }
    }
    
    // MARK: - Permission Management
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            
            if granted {
                print("Notification permission granted")
                // Schedule notifications if enabled
                if dailyReminderEnabled {
                    scheduleNotifications()
                }
            } else {
                print("Notification permission denied")
                // Update UI to reflect permission denial
                await MainActor.run {
                    self.dailyReminderEnabled = false
                }
            }
            
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Notification Scheduling
    
    private func updateNotifications() {
        Task {
            let status = await checkPermissionStatus()
            
            if status == .authorized {
                if dailyReminderEnabled {
                    scheduleNotifications()
                } else {
                    cancelNotifications()
                }
            } else if status == .notDetermined && dailyReminderEnabled {
                // Request permission if user enabled notifications but permission not determined
                _ = await requestPermission()
            }
        }
    }
    
    private func scheduleNotifications() {
        // Cancel existing notifications first
        cancelNotifications()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Prayer Reminder"
        content.body = "Time for your daily prayer practice! 🤲"
        content.sound = .default
        content.badge = 1
        
        // Extract hour and minute from reminderTime
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        // Create trigger for daily notification
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: "dailyPrayerReminder",
            content: content,
            trigger: trigger
        )
        
        // Schedule the notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Daily prayer reminder scheduled for \(components.hour ?? 0):\(String(format: "%02d", components.minute ?? 0))")
            }
        }
    }
    
    private func cancelNotifications() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["dailyPrayerReminder"])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: ["dailyPrayerReminder"])
        print("Prayer reminder notifications cancelled")
    }
    
    // MARK: - Helper Methods
    
    func saveReminderTime() {
        if let encoded = try? JSONEncoder().encode(reminderTime) {
            userDefaults.set(encoded, forKey: "reminderTime")
        }
    }
    
    // For testing purposes - schedule a test notification
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification from PrayerTracker"
        content.sound = .default
        
        // Trigger in 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "testNotification",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling test notification: \(error)")
            } else {
                print("Test notification scheduled")
            }
        }
    }
    
    // Get formatted time string for display
    var formattedReminderTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: reminderTime)
    }
}
