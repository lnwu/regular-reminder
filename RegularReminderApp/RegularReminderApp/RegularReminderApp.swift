import SwiftUI
import UserNotifications

@main
struct RegularReminderApp: App {
    @StateObject private var reminderStore = ReminderStore()
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        // Setup notification categories
        NotificationService.shared.setupNotificationCategories()
        
        // Request notification permission
        NotificationService.shared.requestAuthorization { granted in
            if !granted {
                print("Notification permission not granted")
            }
        }
        
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(reminderStore)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // App became active, refresh notifications
                updateNotifications()
            }
        }
    }
    
    private func updateNotifications() {
        // Reschedule notifications for all enabled reminders
        for reminder in reminderStore.reminders where reminder.isEnabled {
            NotificationService.shared.cancelNotification(for: reminder.id)
            NotificationService.shared.scheduleNotification(for: reminder)
        }
    }
}

/// Handles notification responses
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    static let shared = NotificationDelegate()
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification actions
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let reminderIdString = response.notification.request.content.userInfo["reminderId"] as? String,
              let reminderId = UUID(uuidString: reminderIdString) else {
            completionHandler()
            return
        }
        
        // Post notification to handle action in app
        NotificationCenter.default.post(
            name: .handleReminderAction,
            object: nil,
            userInfo: ["reminderId": reminderId, "action": response.actionIdentifier]
        )
        
        completionHandler()
    }
}

extension Notification.Name {
    static let handleReminderAction = Notification.Name("handleReminderAction")
}
