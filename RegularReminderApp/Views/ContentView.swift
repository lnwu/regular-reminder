import SwiftUI

struct ContentView: View {
    @EnvironmentObject var reminderStore: ReminderStore
    @State private var showingAddReminder = false
    @State private var showingDeveloperSettings = false
    @AppStorage("isDeveloperModeEnabled") private var isDeveloperModeEnabled = false
    
    /// 是否显示开发者入口 - DEBUG 模式下自动启用
    private var showDeveloperEntry: Bool {
        #if DEBUG
        return true
        #else
        return isDeveloperModeEnabled
        #endif
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if reminderStore.isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                } else if reminderStore.reminders.isEmpty {
                    emptyStateView
                } else {
                    reminderListView
                }
            }
            .navigationTitle(NSLocalizedString("app_name", comment: ""))
            .toolbar {
                // 开发者模式按钮 - 放在左侧
                ToolbarItem(placement: .navigationBarLeading) {
                    if showDeveloperEntry {
                        Button(action: { showingDeveloperSettings = true }) {
                            Image(systemName: "gearshape.2")
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // 添加按钮 - 放在右侧
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddReminder = true }) {
                        Image(systemName: "plus")
                    }
                    .disabled(reminderStore.isLoading)
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView()
            }
            .sheet(isPresented: $showingDeveloperSettings) {
                DeveloperSettingsView()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.badge")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(NSLocalizedString("no_reminders", comment: ""))
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text(NSLocalizedString("add_reminder_prompt", comment: ""))
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
                            Label(NSLocalizedString("delete", comment: ""), systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            reminderStore.completeReminder(reminder)
                        } label: {
                            Label(NSLocalizedString("complete", comment: ""), systemImage: "checkmark")
                        }
                        .tint(.green)
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct ReminderRow: View {
    let reminder: Reminder
    @EnvironmentObject var reminderStore: ReminderStore
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
    
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
                    Text("\(NSLocalizedString("next_reminder", comment: "")): \(formattedDate(reminder.nextReminderDate))")
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
                reminderStore.updateReminder(updatedReminder, recalculateDate: false)
            }
        )
    }
    
    private var intervalDescription: String {
        let every = NSLocalizedString("every", comment: "")
        if reminder.intervalValue == 1 {
            return "\(every)\(reminder.intervalType.localizedName)"
        } else {
            return "\(every)\(reminder.intervalValue)\(reminder.intervalType.localizedName)"
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        return Self.dateFormatter.string(from: date)
    }
}

#Preview {
    ContentView()
        .environmentObject(ReminderStore())
}
