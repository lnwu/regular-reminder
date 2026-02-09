import SwiftUI
import UserNotifications

/// 开发者设置视图
struct DeveloperSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ReminderStore.self) private var reminderStore
    @AppStorage("isDeveloperModeEnabled") private var isDeveloperModeEnabled = true
    
    @State private var showResetAlert = false
    @State private var showResetSuccessAlert = false
    @State private var notificationStatus = "未知"
    @State private var pendingCount = 0
    @State private var deliveredCount = 0
    @State private var isLoadingNotifications = false
    
    var body: some View {
        NavigationStack {
            List {
                // 开发者模式开关
                Section {
                    Toggle("开发者模式", isOn: $isDeveloperModeEnabled)
                        .tint(.orange)
                        #if DEBUG
                        .disabled(true)
                        #endif
                } footer: {
                    #if DEBUG
                    Text("DEBUG 模式下开发者入口始终可见")
                    #else
                    Text("关闭后开发者入口将隐藏，需要再次开启才能显示")
                    #endif
                }
                
                // 通知设置区域
                Section(header: Text("通知设置")) {
                    HStack {
                        Text("通知权限状态")
                        Spacer()
                        Text(notificationStatus)
                            .foregroundStyle(statusColor)
                    }
                    
                    Button {
                        openSystemNotificationSettings()
                    } label: {w
                        Label("打开系统通知设置", systemImage: "arrow.up.right.square")
                    }
                    
                    HStack {
                        Text("待处理通知")
                        Spacer()
                        if isLoadingNotifications {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("\(pendingCount)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("已送达通知")
                        Spacer()
                        if isLoadingNotifications {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("\(deliveredCount)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("重置所有通知", systemImage: "bell.slash")
                    }
                    
                    Button {
                        refreshNotificationCounts()
                    } label: {
                        Label("刷新通知状态", systemImage: "arrow.clockwise")
                    }
                    .disabled(isLoadingNotifications)
                }
                
                // 数据调试区域
                Section(header: Text("数据调试")) {
                    HStack {
                        Text("已保存提醒数量")
                        Spacer()
                        Text("\(reminderStore.reminders.count)")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    
                    HStack {
                        Text("已启用提醒数量")
                        Spacer()
                        let enabledCount = reminderStore.reminders.filter { $0.isEnabled }.count
                        Text("\(enabledCount)")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    
                    if !reminderStore.reminders.isEmpty {
                        NavigationLink("查看提醒详情") {
                            ReminderDebugListView(reminders: reminderStore.reminders)
                        }
                    }
                }
                
                // 快捷操作
                Section(header: Text("快捷操作")) {
                    Button {
                        // 重新调度所有通知
                        NotificationService.shared.rescheduleAllNotifications(for: reminderStore.reminders)
                        refreshNotificationCounts()
                    } label: {
                        Label("重新调度所有通知", systemImage: "bell.badge")
                    }
                }
                
                // 关于区域
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("构建版本")
                        Spacer()
                        Text(buildVersion)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("开发者设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .alert("确认重置", isPresented: $showResetAlert) {
                Button("取消", role: .cancel) {}
                Button("重置", role: .destructive) {
                    resetAllNotifications()
                }
            } message: {
                Text("这将取消所有已调度的通知，然后重新为启用的提醒创建通知。此操作不可撤销。")
            }
            .alert("重置成功", isPresented: $showResetSuccessAlert) {
                Button("确定") {}
            } message: {
                Text("所有通知已成功重置。")
            }
            .onAppear {
                checkNotificationStatus()
                refreshNotificationCounts()
            }
        }
    }
    
    /// 状态颜色
    private var statusColor: Color {
        switch notificationStatus {
        case "已授权": return .green
        case "已拒绝": return .red
        case "未决定": return .orange
        default: return .secondary
        }
    }
    
    /// 重置所有通知
    private func resetAllNotifications() {
        NotificationService.shared.rescheduleAllNotifications(for: reminderStore.reminders)
        refreshNotificationCounts()
        showResetSuccessAlert = true
    }
    
    /// 检查通知权限状态
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                switch settings.authorizationStatus {
                case .notDetermined:
                    notificationStatus = "未决定"
                case .denied:
                    notificationStatus = "已拒绝"
                case .authorized:
                    notificationStatus = "已授权"
                case .provisional:
                    notificationStatus = "临时授权"
                case .ephemeral:
                    notificationStatus = "临时授权"
                @unknown default:
                    notificationStatus = "未知"
                }
            }
        }
    }
    
    /// 刷新通知计数
    private func refreshNotificationCounts() {
        isLoadingNotifications = true
        
        let group = DispatchGroup()
        
        group.enter()
        NotificationService.shared.getPendingNotifications { requests in
            pendingCount = requests.count
            group.leave()
        }
        
        group.enter()
        NotificationService.shared.getDeliveredNotifications { notifications in
            deliveredCount = notifications.count
            group.leave()
        }
        
        group.notify(queue: .main) {
            isLoadingNotifications = false
        }
    }
    
    /// 应用版本号
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "未知"
    }
    
    /// 构建版本号
    private var buildVersion: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "未知"
    }
    
    /// 打开系统通知设置
    private func openSystemNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

/// 提醒详情调试列表
struct ReminderDebugListView: View {
    let reminders: [Reminder]
    
    var body: some View {
        List(reminders) { reminder in
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.headline)
                
                LabeledContent("ID", value: reminder.id.uuidString.prefix(8).description)
                LabeledContent("状态", value: reminder.isEnabled ? "启用" : "禁用")
                LabeledContent("间隔", value: "\(reminder.intervalValue) \(reminder.intervalType.localizedName)")
                LabeledContent("下次提醒", value: formatDate(reminder.nextReminderDate))
                if let lastCompleted = reminder.lastCompletedDate {
                    LabeledContent("上次完成", value: formatDate(lastCompleted))
                }
            }
            .font(.caption)
            .padding(.vertical, 4)
        }
        .navigationTitle("提醒详情")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

#Preview {
    DeveloperSettingsView()
        .environment(ReminderStore())
}
