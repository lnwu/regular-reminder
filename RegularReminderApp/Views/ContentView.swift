import SwiftUI

struct ContentView: View {
    @Environment(ReminderStore.self) private var reminderStore
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
            ZStack {
                // 主内容
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
                
                // 右下角悬浮添加按钮
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        AddReminderButton(showingAddReminder: $showingAddReminder)
                            .disabled(reminderStore.isLoading)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("app_name", comment: ""))
            .toolbar {
                // 开发者设置按钮 - 移到右上角
                ToolbarItem(placement: .navigationBarTrailing) {
                    if showDeveloperEntry {
                        Button(action: { showingDeveloperSettings = true }) {
                            Image(systemName: "gearshape.2")
                                .foregroundStyle(.orange)
                        }
                    }
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
        EmptyStateView()
    }
    
    private var reminderListView: some View {
        ReminderListView()
    }
}

// MARK: - Extracted Views

/// 添加提醒按钮（支持 Liquid Glass 效果）
struct AddReminderButton: View {
    @Binding var showingAddReminder: Bool
    
    var body: some View {
        if #available(iOS 26.0, *) {
            Button(action: { showingAddReminder = true }) {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                    .frame(width: 56, height: 56)
            }
            .glassEffect(.regular.interactive(), in: .circle)
        } else {
            Button(action: { showingAddReminder = true }) {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.blue, in: .circle)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
        }
    }
}

/// 空状态视图（支持 Liquid Glass 效果）
struct EmptyStateView: View {
    var body: some View {
        content
            .padding(40)
            .glassBackgroundShape(cornerRadius: 24)
    }
    
    private var content: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.badge")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text(NSLocalizedString("no_reminders", comment: ""))
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text(NSLocalizedString("add_reminder_prompt", comment: ""))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - View Extensions

extension View {
    /// 应用 Liquid Glass 背景形状（iOS 26+），否则使用 material 背景
    @ViewBuilder
    func glassBackgroundShape(cornerRadius: CGFloat) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

/// 提醒列表视图
struct ReminderListView: View {
    @Environment(ReminderStore.self) private var reminderStore
    
    var body: some View {
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
    
    var body: some View {
        ReminderRowContent(reminder: reminder)
            .padding(.vertical, 4)
    }
}

// MARK: - Row Content

/// 提醒行内容视图
struct ReminderRowContent: View {
    let reminder: Reminder
    @Environment(ReminderStore.self) private var reminderStore
    
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
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "bell")
                        .font(.caption)
                    Text("\(NSLocalizedString("next_reminder", comment: "")): \(formattedDate(reminder.nextReminderDate))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
        .environment(ReminderStore())
}
