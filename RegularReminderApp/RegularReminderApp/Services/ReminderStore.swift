import Foundation
import UserNotifications

/// Manages the storage and retrieval of reminders
class ReminderStore: ObservableObject {
    @Published var reminders: [Reminder] = []
    
    private let saveKey = "SavedReminders"
    private let notificationService = NotificationService.shared
    
    init() {
        loadReminders()
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
    
    func updateReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            var updatedReminder = reminder
            updatedReminder.calculateNextReminderDate()
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
            reminders[index].complete()
            saveReminders()
            
            // Reschedule notification for next occurrence
            notificationService.cancelNotification(for: reminder.id)
            if reminders[index].isEnabled {
                notificationService.scheduleNotification(for: reminders[index])
            }
        }
    }
    
    func snoozeReminder(_ reminder: Reminder, by days: Int) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].snooze(by: days)
            saveReminders()
            
            // Reschedule notification
            notificationService.cancelNotification(for: reminder.id)
            if reminders[index].isEnabled {
                notificationService.scheduleNotification(for: reminders[index])
            }
        }
    }
    
    private func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Reminder].self, from: data) {
            reminders = decoded
        }
    }
}
