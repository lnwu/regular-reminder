import Foundation
import UserNotifications

/// Manages the storage and retrieval of reminders
@Observable
@MainActor
class ReminderStore {
    var reminders: [Reminder] = []
    var isLoading = true
    
    private let saveKey = "SavedReminders"
    private let notificationService = NotificationService.shared
    
    init() {
        // 启动时立即同步加载数据，这样用户打开应用就能看到内容
        // 这是轻量级操作，不会阻塞主线程太久
        loadReminders()
        
        // 数据加载完成，标记为不处于 loading 状态
        self.isLoading = false
    }
    
    /// 异步刷新提醒数据（用于应用从后台返回时）
    /// 不会触发 isLoading，避免界面闪烁
    func refreshReminders() async {
        // 在后台线程读取 UserDefaults
        let loadedReminders = await Task.detached(priority: .userInitiated) { () -> [Reminder] in
            if let data = UserDefaults.standard.data(forKey: self.saveKey),
               let decoded = try? JSONDecoder().decode([Reminder].self, from: data) {
                return decoded
            }
            return []
        }.value
        
        // 只在数据有变化时才更新，避免不必要的 UI 刷新
        if loadedReminders != self.reminders {
            self.reminders = loadedReminders
        }
    }
    
    /// 同步加载（仅在需要时保留，如 Siri Intent）
    func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Reminder].self, from: data) {
            reminders = decoded
        }
    }
    
    func addReminder(_ reminder: Reminder) {
        var newReminder = reminder
        newReminder.calculateNextReminderDate()
        reminders.append(newReminder)
        saveReminders()
        
        if newReminder.isEnabled {
            notificationService.scheduleNotification(for: newReminder)
        }
    }
    
    func updateReminder(_ reminder: Reminder, recalculateDate: Bool = false) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            var updatedReminder = reminder
            
            // Only recalculate nextReminderDate if interval/start date changed
            if recalculateDate {
                updatedReminder.calculateNextReminderDate()
            }
            
            reminders[index] = updatedReminder
            saveReminders()
            
            // Cancel existing notification and reschedule if enabled
            notificationService.cancelNotification(for: reminder.id)
            if updatedReminder.isEnabled {
                notificationService.scheduleNotification(for: updatedReminder)
            }
        }
    }
    
    func deleteReminder(_ reminder: Reminder) {
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
        notificationService.cancelNotification(for: reminder.id)
    }
    
    func completeReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            var updatedReminder = reminders[index]
            updatedReminder.complete()
            reminders[index] = updatedReminder
            saveReminders()
            
            // Reschedule notification for next occurrence
            notificationService.cancelNotification(for: reminder.id)
            if updatedReminder.isEnabled {
                notificationService.scheduleNotification(for: updatedReminder)
            }
        }
    }
    
    func snoozeReminder(_ reminder: Reminder, by days: Int) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            var snoozedReminder = reminders[index]
            snoozedReminder.snooze(by: days)
            reminders[index] = snoozedReminder
            saveReminders()
            
            // Reschedule notification
            notificationService.cancelNotification(for: reminder.id)
            if snoozedReminder.isEnabled {
                notificationService.scheduleNotification(for: snoozedReminder)
            }
        }
    }
    
    /// Reloads reminders from UserDefaults
    /// Called when app becomes active or when reminders are updated externally (e.g., via Siri)
    func reloadReminders() {
        loadReminders()
    }
    
    private func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}
