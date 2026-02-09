import Foundation
import UserNotifications

/// Manages local notifications for reminders
class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            Task { @MainActor in
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
    
    // MARK: - Debug Functions
    
    /// 获取所有待处理的通知请求
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            Task { @MainActor in
                completion(requests)
            }
        }
    }
    
    /// 获取已送达的通知
    func getDeliveredNotifications(completion: @escaping ([UNNotification]) -> Void) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            Task { @MainActor in
                completion(notifications)
            }
        }
    }
    
    /// 取消所有通知（包括待处理和已送达的）
    func cancelAllNotifications() {
        // 取消所有待处理的通知
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        // 移除所有已送达的通知
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        // 清除角标
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    /// 重新调度所有启用的提醒通知
    func rescheduleAllNotifications(for reminders: [Reminder]) {
        // 先取消所有
        cancelAllNotifications()
        
        // 重新为启用的提醒调度
        for reminder in reminders where reminder.isEnabled {
            scheduleNotification(for: reminder)
        }
    }
}
