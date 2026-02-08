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
        content.title = NSLocalizedString("reminder_notification_title", comment: "")
        content.body = reminder.title
        content.sound = .default
        content.categoryIdentifier = "REMINDER_CATEGORY"
        content.userInfo = ["reminderId": reminder.id.uuidString]
        
        // Use calendar trigger for better reliability with long intervals
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], 
                                                 from: reminder.nextReminderDate)
        
        // Only schedule if the date is in the future
        if reminder.nextReminderDate > Date() {
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
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
            title: NSLocalizedString("complete", comment: ""),
            options: []
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: NSLocalizedString("snooze_1_day", comment: ""),
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
