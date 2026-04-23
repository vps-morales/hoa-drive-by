import Foundation
import UIKit
import UserNotifications

struct NotificationService {
    static let shared = NotificationService()

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    func scheduleViolationCreated(
        title: String,
        community: String,
        property: String,
        timeInterval: TimeInterval = 2
    ) {
        let content = UNMutableNotificationContent()
        content.title = "New Violation"
        content.body = "\(title) at \(property), \(community)"
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    func scheduleViolationStatusChanged(
        violation: String,
        newStatus: String,
        timeInterval: TimeInterval = 2
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Status Updated"
        content.body = "\(violation) is now \(newStatus)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    func scheduleDailySummary(
        openCount: Int,
        resolvedCount: Int,
        escalatedCount: Int,
        timeInterval: TimeInterval = 86400
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Summary"
        content.body = "Open: \(openCount) | Resolved: \(resolvedCount) | Escalated: \(escalatedCount)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "daily-summary", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
}
