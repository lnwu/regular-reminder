import SwiftUI
import UserNotifications

@main
struct RegularReminderApp: App {
    @State private var reminderStore = ReminderStore()
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        // 只做最轻量级的初始化
        #if targetEnvironment(simulator)
        UserDefaults.standard.set(false, forKey: "haptic_feedback_enabled")
        #endif
        
        // 设置通知代理
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(reminderStore)
                .task {
                    // 启动时数据已经通过 init() 加载好了
                    // 这里只需要在后台设置通知相关的内容
                    
                    // 1. 设置通知类别（后台执行）
                    await Task.detached(priority: .background) {
                        NotificationService.shared.setupNotificationCategories()
                    }.value
                    
                    // 2. 异步刷新通知（后台执行，不阻塞 UI）
                    Task.detached(priority: .background) {
                        await self.refreshNotificationsAsync()
                    }
                    
                    // 3. 延迟请求通知权限（不阻塞启动）
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒后
                    await MainActor.run {
                        NotificationService.shared.requestAuthorization { granted in
                            if !granted {
                                print("Notification permission not granted")
                            }
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .reloadReminders)) { _ in
                    reminderStore.reloadReminders()
                }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // 应用回到前台时静默刷新数据（不显示 loading）
                Task {
                    await reminderStore.refreshReminders()
                }
            }
        }
    }
    
    /// 异步刷新通知，不阻塞主线程
    private func refreshNotificationsAsync() async {
        let enabledReminders = reminderStore.reminders.filter { $0.isEnabled }
        
        // 分批处理，每批之间让出时间片
        let batchSize = 5
        for i in stride(from: 0, to: enabledReminders.count, by: batchSize) {
            let end = min(i + batchSize, enabledReminders.count)
            let batch = Array(enabledReminders[i..<end])
            
            // 在后台线程处理通知
            await Task.detached(priority: .background) {
                for reminder in batch {
                    NotificationService.shared.cancelNotification(for: reminder.id)
                    NotificationService.shared.scheduleNotification(for: reminder)
                }
            }.value
            
            // 小延迟让出时间片
            if end < enabledReminders.count {
                try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
            }
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
