import SwiftUI
import UserNotifications

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - Request Permission
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if granted {
                print("Notification permission granted")
                DispatchQueue.main.async {
                    self.scheduleDailyNotification()
                }
            }
        }
    }

    // MARK: - Daily 9AM Notification
    func scheduleDailyNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "Snippets"
        content.body = randomPrompt()
        content.sound = .default
        content.userInfo = ["destination": "prompt"]

        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "daily_prompt",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Test Notification (fires in 5 seconds)
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Snippets"
        content.body = randomPrompt()
        content.sound = .default
        content.userInfo = ["destination": "prompt"]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "test_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { _ in
            print("Test notification fires in 5 seconds — background the app now!")
        }
    }

    // MARK: - Show banner even when app is open
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    // MARK: - Handle tap on notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let destination = userInfo["destination"] as? String,
           destination == "prompt" {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name("NavigateToPrompt"),
                    object: nil
                )
            }
        }
        completionHandler()
    }

    func randomPrompt() -> String {
        PromptData.prompts.randomElement() ?? "Capture something beautiful today"
    }
}
