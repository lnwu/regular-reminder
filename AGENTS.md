# 定时提醒 (Regular Reminder) - AI 开发指南

## 项目概述

**定时提醒**是一个原生的 iOS 应用程序，用于创建和管理周期性提醒事项。该应用遵循 Apple 的人机界面指南 (HIG)，使用 SwiftUI 构建，专注于中文用户体验。

### 核心功能

- **周期性提醒管理**：支持天、周、月、年多种周期类型
- **自然语言输入**：支持中文自然语言解析（如"每两周换被罩"）
- **本地通知**：到期自动推送提醒，支持完成和延后操作
- **Siri 集成**：通过 App Intents 支持语音添加提醒

### 技术栈

- **SwiftUI**：现代化的声明式 UI 框架
- **@Observable**：新一代响应式状态管理
- **UserNotifications**：本地通知管理
- **App Intents**：Siri 快捷指令集成
- **UserDefaults**：轻量级本地数据持久化

## 项目结构

```
RegularReminderApp/
├── Models/
│   └── Reminder.swift              # 提醒数据模型
├── Views/
│   ├── ContentView.swift           # 主界面视图
│   ├── AddReminderView.swift       # 添加提醒视图
│   └── DeveloperSettingsView.swift # 开发者调试视图
├── Services/
│   ├── ReminderStore.swift         # 提醒数据存储管理
│   ├── NotificationService.swift   # 通知服务管理
│   └── NaturalLanguageParser.swift # 自然语言解析服务
├── Intents/
│   └── AddReminderIntent.swift     # Siri 意图定义
├── Assets.xcassets/                # 应用资源
├── zh-Hans.lproj/
│   └── Localizable.strings         # 简体中文本地化
├── Info.plist                      # 应用配置
├── LaunchScreen.storyboard         # 启动屏幕
├── RegularReminderApp.swift        # 应用入口
└── TestLaunchApp.swift             # 启动性能测试入口
```

## 系统要求

- **iOS 版本**：iOS 17.0 或更高版本
- **开发环境**：Xcode 15.0 或更高版本
- **macOS**：macOS 13.0 (Ventura) 或更高版本
- **部署目标**：iPhone 和 iPad

## 构建和运行

### 使用 Xcode 构建

```bash
# 打开项目
open RegularReminder.xcodeproj

# 使用 xcodebuild 命令行构建
xcodebuild -project RegularReminder.xcodeproj -scheme RegularReminder -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build
```

### 运行测试

在 Xcode 中：

1. 选择目标设备（模拟器或真机）
2. 按 `⌘ + R` 或点击运行按钮

### 开发者模式

- **DEBUG 模式**：开发者入口自动显示
- **Release 模式**：通过 `DeveloperSettingsView` 手动开启开发者模式

## 代码风格指南

### 状态管理

- **优先使用 `@Observable`** 替代 `ObservableObject`
- **`@Observable` 类标记 `@MainActor`** 确保线程安全
- **`@State` 必须声明为 `private`**
- **注入的观察对象使用 `@Bindable`**

```swift
// 推荐
@Observable
@MainActor
class ReminderStore {
    var reminders: [Reminder] = []
}

// 视图使用
@State private var reminderStore = ReminderStore()
// 或注入
@Environment(ReminderStore.self) private var reminderStore
```

### 现代 API 使用

| 已弃用                       | 现代替代                          |
| ---------------------------- | --------------------------------- |
| `foregroundColor()`          | `foregroundStyle()`               |
| `cornerRadius()`             | `clipShape(.rect(cornerRadius:))` |
| `NavigationView`             | `NavigationStack`                 |
| `onChange(of:) { value in }` | `onChange(of:) { old, new in }`   |
| `fontWeight(.bold)`          | `bold()`                          |

### 视图结构

- 复杂视图提取为独立子视图
- 使用 `@ViewBuilder` 修饰器处理条件 UI
- 避免在 `body` 中内联复杂逻辑
- 支持 iOS 26+ Liquid Glass 效果，并提供降级方案

```swift
@ViewBuilder
func glassBackgroundShape(cornerRadius: CGFloat) -> some View {
    if #available(iOS 26.0, *) {
        self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
    } else {
        self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
    }
}
```

## 架构设计

### 数据流

```
User Input → View → ReminderStore → UserDefaults
                      ↓
              NotificationService → UserNotifications
```

### 核心组件

1. **Reminder** (Model): 纯数据模型，遵循 `Codable`, `Identifiable`, `Equatable`
2. **ReminderStore** (Service): 数据管理，封装所有 CRUD 操作
3. **NotificationService**: 通知调度管理，单例模式
4. **NaturalLanguageParser**: 中文自然语言解析器
5. **NotificationDelegate**: 处理通知响应动作

### 本地化

所有用户可见字符串使用 `NSLocalizedString`，定义在 `zh-Hans.lproj/Localizable.strings` 中：

```swift
Text(NSLocalizedString("app_name", comment: ""))
```

## 测试策略

### 启动性能测试

使用 `TestLaunchApp.swift` 作为诊断工具：

1. 在 Scheme 中将入口改为 `TestLaunchApp`
2. 运行并观察渲染时间
3. 时间超过 1s 表示需要优化

### 调试工具

- **DeveloperSettingsView**: 提供通知状态监控、数据重置等功能
- **通知计数器**: 查看待处理和已送达通知数量
- **数据查看器**: 查看已保存提醒的详细信息

## 安全与隐私

### 数据存储

- 所有数据存储在本地 UserDefaults
- 不涉及服务器通信
- 不收集任何用户隐私数据

### 权限

- **通知权限**：应用启动时请求，用于发送定时提醒

### 安全建议

- 敏感操作（如批量删除）需要二次确认
- 通知内容仅包含提醒标题

## 开发约定

### 注释规范

- 使用中文注释解释复杂逻辑
- 关键功能添加文档注释

### 命名规范

- 类名/结构体：PascalCase
- 方法/属性：camelCase
- 常量：描述性命名，无需特定前缀

### 文件组织

- 按功能模块分目录（Models, Views, Services, Intents）
- 每个文件专注于单一职责

## 关键代码模式

### 提醒数据模型

```swift
struct Reminder: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var startDate: Date
    var intervalType: IntervalType
    var intervalValue: Int
    var isEnabled: Bool
    var lastCompletedDate: Date?
    var nextReminderDate: Date
}

enum IntervalType: String, Codable, CaseIterable {
    case days = "天"
    case weeks = "周"
    case months = "月"
    case years = "年"
}
```

### 通知处理流程

1. 用户完成/延后通知动作
2. `NotificationDelegate` 接收响应
3. 更新 UserDefaults 中的提醒数据
4. 重新计算下次提醒时间
5. 调度新的通知
6. 通过 `NotificationCenter` 通知应用刷新

### 自然语言解析

支持模式：`每` + [数字] + [单位] + [事项]

示例：

- "每两周换被罩" → interval: 2 weeks, title: "换被罩"
- "每3天浇花" → interval: 3 days, title: "浇花"
- "每年体检" → interval: 1 year, title: "体检"

## 注意事项

1. **UserDefaults 数据**：确保 `Reminder` 结构变更时考虑向后兼容性
2. **通知权限**：用户拒绝权限后应用仍能正常使用，只是无法接收提醒
3. **后台刷新**：应用从后台返回时会静默刷新数据
4. **Siri Intent**：独立管理数据，不依赖 `ReminderStore`
5. **Liquid Glass**：iOS 26+ 特性，必须提供降级方案

## 参考资源

- [iOS 人机界面指南](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI 官方文档](https://developer.apple.com/documentation/swiftui)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- 项目技能文件：`.agents/skills/mobile-ios-design/SKILL.md`
- 项目技能文件：`.agents/skills/swiftui-expert-skill/SKILL.md`
