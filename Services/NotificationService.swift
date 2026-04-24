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

    private func schedule(title: String, body: String, identifier: String, badge: Bool = false) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        if badge {
            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    func scheduleViolationCreated(
        title: String,
        community: String,
        property: String
    ) {
        schedule(
            title: "New Violation",
            body: "\(title) at \(property), \(community)",
            identifier: UUID().uuidString,
            badge: true
        )
    }

    func scheduleViolationStatusChanged(
        violation: String,
        newStatus: String
    ) {
        schedule(
            title: "Status Updated",
            body: "\(violation) is now \(newStatus)",
            identifier: UUID().uuidString
        )
    }

    func scheduleDailySummary(
        openCount: Int,
        resolvedCount: Int,
        escalatedCount: Int
    ) {
        schedule(
            title: "Daily Summary",
            body: "Open: \(openCount) | Resolved: \(resolvedCount) | Escalated: \(escalatedCount)",
            identifier: "daily-summary"
        )
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
}
