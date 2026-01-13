import Foundation
import UserNotifications

/// Manages local notifications for reminders
class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = "定时提醒"
        content.body = reminder.title
        content.sound = .default
        content.categoryIdentifier = "REMINDER_CATEGORY"
        content.userInfo = ["reminderId": reminder.id.uuidString]
        
        // Calculate time interval from now to next reminder date
        let timeInterval = reminder.nextReminderDate.timeIntervalSince(Date())
        
        // Only schedule if the date is in the future
        if timeInterval > 0 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: reminder.id.uuidString, 
                                               content: content, 
                                               trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
    
    func cancelNotification(for reminderId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderId.uuidString])
    }
    
    func setupNotificationCategories() {
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_ACTION",
            title: "完成",
            options: []
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "延后1天",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "REMINDER_CATEGORY",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
