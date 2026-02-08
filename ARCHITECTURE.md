# 架构设计文档 (Architecture Design)

## 概述

定时提醒是一个使用 SwiftUI 构建的原生 iOS 应用，采用 MVVM (Model-View-ViewModel) 架构模式，专注于为用户提供简洁、高效的周期性提醒功能。

## 技术栈

### 核心框架
- **SwiftUI**: UI 框架
- **Combine**: 响应式数据流
- **Foundation**: 基础功能
- **UserNotifications**: 本地通知
- **App Intents**: Siri 集成

### 数据存储
- **UserDefaults**: 轻量级本地数据持久化

### 开发要求
- **iOS**: 17.0+
- **Swift**: 5.9+
- **Xcode**: 15.0+

## 架构设计

### 整体架构图

```
┌─────────────────────────────────────────┐
│           User Interface (SwiftUI)       │
│  ┌──────────────┐    ┌───────────────┐  │
│  │ ContentView  │    │AddReminderView│  │
│  └──────────────┘    └───────────────┘  │
└──────────────┬──────────────────────────┘
               │ @EnvironmentObject
               ↓
┌─────────────────────────────────────────┐
│        State Management (Combine)        │
│  ┌────────────────────────────────────┐  │
│  │      ReminderStore (@Published)    │  │
│  └────────────────────────────────────┘  │
└──────────┬─────────────────┬────────────┘
           │                 │
           ↓                 ↓
┌──────────────────┐  ┌──────────────────┐
│  Data Models     │  │    Services      │
│  - Reminder      │  │  - Notification  │
│  - IntervalType  │  │  - NLParser      │
└──────────────────┘  │  - UserDefaults  │
                      └──────────────────┘
           │                 │
           └────────┬────────┘
                    ↓
           ┌─────────────────┐
           │  iOS System     │
           │  - Notifications│
           │  - Siri/Intents │
           └─────────────────┘
```

## 模块说明

### 1. Models (数据模型层)

#### Reminder.swift
```swift
struct Reminder: Identifiable, Codable {
    var id: UUID
    var title: String
    var startDate: Date
    var intervalType: IntervalType
    var intervalValue: Int
    var isEnabled: Bool
    var lastCompletedDate: Date?
    var nextReminderDate: Date
}
```

**职责：**
- 定义提醒的数据结构
- 提供日期计算逻辑
- 实现 Codable 以支持序列化

**关键方法：**
- `calculateNextReminderDate()`: 计算下次提醒时间
- `complete()`: 标记为完成并更新下次时间
- `snooze(by:)`: 延后提醒

#### IntervalType.swift
```swift
enum IntervalType: String, Codable, CaseIterable {
    case days = "天"
    case weeks = "周"
    case months = "月"
    case years = "年"
}
```

**职责：**
- 定义时间间隔类型
- 提供本地化支持

### 2. Services (服务层)

#### ReminderStore.swift

**职责：**
- 管理提醒数据的 CRUD 操作
- 与 UserDefaults 交互进行数据持久化
- 协调通知服务

**关键方法：**
```swift
class ReminderStore: ObservableObject {
    @Published var reminders: [Reminder]
    
    func addReminder(_ reminder: Reminder)
    func updateReminder(_ reminder: Reminder)
    func deleteReminder(_ reminder: Reminder)
    func completeReminder(_ reminder: Reminder)
    func snoozeReminder(_ reminder: Reminder, by days: Int)
}
```

#### NotificationService.swift

**职责：**
- 管理本地通知的创建、更新、取消
- 请求通知权限
- 配置通知分类和操作

**关键方法：**
```swift
class NotificationService {
    func requestAuthorization(completion: @escaping (Bool) -> Void)
    func scheduleNotification(for reminder: Reminder)
    func cancelNotification(for reminderId: UUID)
    func setupNotificationCategories()
}
```

**通知操作：**
- `COMPLETE_ACTION`: 完成提醒
- `SNOOZE_ACTION`: 延后1天

#### NaturalLanguageParser.swift

**职责：**
- 解析中文自然语言输入
- 提取周期信息（数字、单位、标题）
- 返回 Reminder 对象或 nil

**解析模式：**
```
输入格式: 每[数字][时间单位][任务描述]
示例: 每两周换被罩
解析结果: 
  - intervalValue: 2
  - intervalType: .weeks
  - title: "换被罩"
```

**支持的模式：**
- 数字：阿拉伯数字、中文数字（一、两、三等）
- 单位：天、周、星期、月、个月、年

### 3. Views (视图层)

#### ContentView.swift

**职责：**
- 显示提醒列表
- 处理空状态
- 提供导航和操作按钮
- 响应通知操作

**UI 组件：**
- NavigationStack
- List with ReminderRow
- Empty state view
- Swipe actions (完成/删除)

#### AddReminderView.swift

**职责：**
- 提供添加提醒的界面
- 支持自然语言和手动输入两种模式
- 实时解析预览
- 表单验证

**UI 组件：**
- Toggle (切换输入模式)
- TextField (自然语言输入)
- Form fields (手动输入)
- 实时解析反馈

#### ReminderRow.swift

**职责：**
- 显示单个提醒信息
- 提供启用/禁用开关
- 格式化显示日期和周期

### 4. Intents (Siri 集成层)

#### AddReminderIntent.swift

**职责：**
- 定义 Siri 可以调用的操作
- 处理语音输入并创建提醒
- 提供语音反馈

**App Shortcuts：**
```swift
@available(iOS 16.0, *)
struct AddReminderIntent: AppIntent {
    @Parameter(title: "提醒内容")
    var reminderText: String
    
    func perform() async throws -> some IntentResult & ProvidesDialog
}
```

## 数据流

### 1. 添加提醒流程

```
用户输入
   ↓
AddReminderView
   ↓
NaturalLanguageParser (如果使用自然语言)
   ↓
Reminder 对象
   ↓
ReminderStore.addReminder()
   ↓
├── UserDefaults (持久化)
└── NotificationService.scheduleNotification() (设置通知)
```

### 2. 完成提醒流程

```
用户操作 (滑动或通知)
   ↓
ReminderStore.completeReminder()
   ↓
├── 更新 Reminder (lastCompletedDate, nextReminderDate)
├── UserDefaults (保存)
└── NotificationService
    ├── cancelNotification() (取消旧通知)
    └── scheduleNotification() (创建新通知)
```

### 3. Siri 添加提醒流程

```
用户语音命令
   ↓
iOS Siri Engine
   ↓
AddReminderIntent.perform()
   ↓
NaturalLanguageParser.parseReminder()
   ↓
直接保存到 UserDefaults
   ↓
NotificationService.scheduleNotification()
   ↓
语音反馈给用户
```

## 状态管理

### 使用 Combine 框架

```swift
ReminderStore: ObservableObject
   ↓
@Published var reminders: [Reminder]
   ↓
SwiftUI Views (@EnvironmentObject)
   ↓
自动 UI 更新
```

**优势：**
- 单向数据流，易于调试
- 自动 UI 刷新
- 类型安全

## 持久化策略

### UserDefaults 存储

```swift
// 保存
let encoded = JSONEncoder().encode(reminders)
UserDefaults.standard.set(encoded, forKey: "SavedReminders")

// 加载
let data = UserDefaults.standard.data(forKey: "SavedReminders")
let reminders = JSONDecoder().decode([Reminder].self, from: data)
```

**选择 UserDefaults 的原因：**
- 数据量小（提醒列表）
- 简单易用
- 无需复杂的数据库
- 符合 iOS 最佳实践

**未来改进：**
- 迁移到 Core Data（支持更复杂查询）
- 或使用 SwiftData（iOS 17+）
- iCloud 同步

## 通知系统设计

### 本地通知策略

```swift
UNTimeIntervalNotificationTrigger
   ↓
基于 nextReminderDate 计算 timeInterval
   ↓
一次性通知（不使用重复）
   ↓
完成后重新计算并调度新通知
```

**为什么不使用重复通知：**
- 需要灵活的周期（如每2周）
- 支持延后功能
- 需要跟踪完成状态

### 通知分类和操作

```swift
Category: REMINDER_CATEGORY
   ├── Action: COMPLETE_ACTION (完成)
   └── Action: SNOOZE_ACTION (延后1天)
```

## 自然语言处理

### 解析策略

1. **模式匹配**
   - 查找关键词（天、周、月、年）
   - 提取数字（阿拉伯或中文）
   - 分离任务描述

2. **正则表达式**
   ```
   每[数字]?[时间单位][任务]
   ```

3. **错误处理**
   - 无法识别时返回 nil
   - 提示用户调整表述或使用手动模式

### 支持的格式

```
✅ 每[N][单位][任务]    // 每两周换被罩
✅ 每[单位][任务]        // 每周打扫（默认1）
✅ 每[N][单位]          // 每两周（默认标题）
```

## 设计原则

### 1. iOS 原生体验

- 使用系统原生控件
- SF Symbols 图标系统
- 标准手势（滑动操作）
- 遵循 Human Interface Guidelines

### 2. 简洁优先

- 最少的配置选项
- 清晰的视觉层次
- 直观的操作流程

### 3. 可靠性

- 本地存储（不依赖网络）
- 系统级通知（后台运行）
- 数据持久化

### 4. 可扩展性

- 模块化设计
- 清晰的职责分离
- 易于添加新功能

## 性能优化

### 1. 数据加载
- 延迟加载提醒列表
- 使用 Codable 高效序列化

### 2. UI 渲染
- SwiftUI 自动优化
- 列表虚拟化（List）

### 3. 通知调度
- 批量取消和重新调度
- 避免重复通知

## 安全和隐私

### 数据保护
- 本地存储，不上传云端
- 使用沙盒机制
- 遵守 iOS 隐私政策

### 权限管理
- 仅请求必要权限（通知）
- 清晰的权限说明
- 优雅的拒绝处理

## 测试策略

### 单元测试
- 模型逻辑（日期计算）
- 自然语言解析
- 数据持久化

### UI 测试
- 添加提醒流程
- 完成提醒流程
- 导航和交互

### 集成测试
- 通知调度
- Siri 集成
- 数据一致性

## 未来改进方向

### 短期（v1.1）
- [ ] 编辑已有提醒
- [ ] 提醒分类/标签
- [ ] 自定义通知时间

### 中期（v2.0）
- [ ] iCloud 同步
- [ ] Widget 支持
- [ ] Apple Watch 应用

### 长期（v3.0）
- [ ] 提醒统计和分析
- [ ] 习惯追踪
- [ ] 家庭共享

## 参考文档

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications)
- [App Intents](https://developer.apple.com/documentation/appintents)
