import SwiftUI

struct ContentView: View {
    @EnvironmentObject var reminderStore: ReminderStore
    @State private var showingAddReminder = false
    
    var body: some View {
        NavigationStack {
            Group {
                if reminderStore.reminders.isEmpty {
                    emptyStateView
                } else {
                    reminderListView
                }
            }
            .navigationTitle("定时提醒")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddReminder = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView()
            }
            .onReceive(NotificationCenter.default.publisher(for: .handleReminderAction)) { notification in
                handleReminderAction(notification)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.badge")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("暂无提醒")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("点击 + 添加新的定时提醒")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var reminderListView: some View {
        List {
            ForEach(reminderStore.reminders) { reminder in
                ReminderRow(reminder: reminder)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            reminderStore.deleteReminder(reminder)
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            reminderStore.completeReminder(reminder)
                        } label: {
                            Label("完成", systemImage: "checkmark")
                        }
                        .tint(.green)
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func handleReminderAction(_ notification: Notification) {
        guard let reminderId = notification.userInfo?["reminderId"] as? UUID,
              let action = notification.userInfo?["action"] as? String,
              let reminder = reminderStore.reminders.first(where: { $0.id == reminderId }) else {
            return
        }
        
        switch action {
        case "COMPLETE_ACTION":
            reminderStore.completeReminder(reminder)
        case "SNOOZE_ACTION":
            reminderStore.snoozeReminder(reminder, by: 1)
        default:
            break
        }
    }
}

struct ReminderRow: View {
    let reminder: Reminder
    @EnvironmentObject var reminderStore: ReminderStore
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.headline)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(intervalDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "bell")
                        .font(.caption)
                    Text("下次: \(formattedDate(reminder.nextReminderDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: binding)
                .labelsHidden()
        }
    }
    
    private var binding: Binding<Bool> {
        Binding(
            get: { reminder.isEnabled },
            set: { newValue in
                var updatedReminder = reminder
                updatedReminder.isEnabled = newValue
                reminderStore.updateReminder(updatedReminder)
            }
        )
    }
    
    private var intervalDescription: String {
        if reminder.intervalValue == 1 {
            return "每\(reminder.intervalType.localizedName)"
        } else {
            return "每\(reminder.intervalValue)\(reminder.intervalType.localizedName)"
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
        .environmentObject(ReminderStore())
}
