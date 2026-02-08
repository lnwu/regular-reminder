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
                .onReceive(NotificationCenter.default.publisher(for: .reloadReminders)) { _ in
                    reminderStore.reloadReminders()
                }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // App became active, reload reminders and refresh notifications
                reminderStore.reloadReminders()
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
        
        let actionIdentifier = response.actionIdentifier
        
        // Load reminders from UserDefaults
        var reminders = loadReminders()
        guard let index = reminders.firstIndex(where: { $0.id == reminderId }) else {
            completionHandler()
            return
        }
        
        switch actionIdentifier {
        case "COMPLETE_ACTION":
            // Mark as completed
            var updatedReminder = reminders[index]
            updatedReminder.complete()
            reminders[index] = updatedReminder
            saveReminders(reminders)
            
            // Reschedule notification for next occurrence
            if updatedReminder.isEnabled {
                NotificationService.shared.scheduleNotification(for: updatedReminder)
            }
            
        case "SNOOZE_ACTION":
            // Snooze by 1 day
            var updatedReminder = reminders[index]
            updatedReminder.snooze(by: 1)
            reminders[index] = updatedReminder
            saveReminders(reminders)
            
            // Reschedule notification
            if updatedReminder.isEnabled {
                NotificationService.shared.scheduleNotification(for: updatedReminder)
            }
            
        default:
            break
        }
        
        // Notify app to reload if it's running
        NotificationCenter.default.post(
            name: .reloadReminders,
            object: nil
        )
        
        completionHandler()
    }
    
    private func loadReminders() -> [Reminder] {
        if let data = UserDefaults.standard.data(forKey: "SavedReminders"),
           let decoded = try? JSONDecoder().decode([Reminder].self, from: data) {
            return decoded
        }
        return []
    }
    
    private func saveReminders(_ reminders: [Reminder]) {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: "SavedReminders")
        }
    }
}

extension Notification.Name {
    static let reloadReminders = Notification.Name("reloadReminders")
}
