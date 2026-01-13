import Foundation
import AppIntents

/// App Intent for adding a reminder via Siri
@available(iOS 16.0, *)
struct AddReminderIntent: AppIntent {
    static var title: LocalizedStringResource = "添加提醒"
    static var description = IntentDescription("使用Siri添加一个定时提醒")
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "提醒内容")
    var reminderText: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("添加提醒 \(\.$reminderText)")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let parser = NaturalLanguageParser()
        
        guard let reminder = parser.parseReminder(from: reminderText) else {
            return .result(dialog: "无法识别提醒内容，请尝试说：每两周换被罩")
        }
        
        // Save reminder to UserDefaults
        var reminders = loadReminders()
        var newReminder = reminder
        newReminder.calculateNextReminderDate()
        reminders.append(newReminder)
        saveReminders(reminders)
        
        // Schedule notification
        NotificationService.shared.scheduleNotification(for: newReminder)
        
        let intervalDesc = newReminder.intervalValue == 1 ? 
            "每\(newReminder.intervalType.localizedName)" : 
            "每\(newReminder.intervalValue)\(newReminder.intervalType.localizedName)"
        
        return .result(dialog: "已添加提醒：\(newReminder.title)，\(intervalDesc)")
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

/// App shortcuts for quick access
@available(iOS 16.0, *)
struct ReminderAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddReminderIntent(),
            phrases: [
                "添加\(.applicationName)提醒",
                "在\(.applicationName)中添加提醒",
                "使用\(.applicationName)添加提醒"
            ],
            shortTitle: "添加提醒",
            systemImageName: "bell.badge.fill"
        )
    }
}
