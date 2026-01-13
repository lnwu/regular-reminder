# 定时提醒 (Regular Reminder)

一个原生的 iOS 应用，用于创建和管理周期性提醒。

## 功能特性

### ✅ 已实现功能

- **周期性提醒管理**
  - 添加自定义周期提醒（天、周、月、年）
  - 编辑和删除提醒
  - 开关提醒启用状态
  - 查看下次提醒时间

- **自然语言输入** 📝
  - 支持中文自然语言解析
  - 示例：
    - "每两周换被罩"
    - "每3天浇花"
    - "每个月还信用卡"
    - "每年体检"
  - 自动识别周期类型和间隔

- **本地通知** 🔔
  - 到期时自动发送提醒通知
  - 通知操作：完成或延后
  - 延后功能：延后1天

- **Siri 集成** 🗣️
  - App Intents 支持
  - 通过 Siri 添加提醒
  - 语音命令示例："添加定时提醒每两周换被罩"

- **原生 iOS 设计** 🎨
  - 使用 SwiftUI 构建
  - 遵循 iOS 人机界面指南
  - 使用系统原生 SF Symbols 图标
  - 支持浅色和深色模式
  - 原生手势支持（滑动删除、滑动完成）

## 技术栈

- **SwiftUI** - 现代化的 UI 框架
- **Combine** - 响应式编程
- **UserNotifications** - 本地通知
- **App Intents** - Siri 快捷指令支持
- **UserDefaults** - 数据持久化

## 项目结构

```
RegularReminderApp/
├── RegularReminderApp/
│   ├── Models/
│   │   └── Reminder.swift          # 提醒数据模型
│   ├── Views/
│   │   ├── ContentView.swift       # 主界面
│   │   └── AddReminderView.swift   # 添加提醒界面
│   ├── Services/
│   │   ├── ReminderStore.swift     # 提醒存储管理
│   │   ├── NotificationService.swift   # 通知服务
│   │   └── NaturalLanguageParser.swift # 自然语言解析
│   ├── Intents/
│   │   └── AddReminderIntent.swift # Siri 意图
│   ├── Assets.xcassets/            # 资源文件
│   ├── Info.plist                  # 应用配置
│   └── RegularReminderApp.swift    # 应用入口
└── RegularReminder.xcodeproj/      # Xcode 项目文件
```

## 使用方法

### 添加提醒

1. **自然语言方式**（推荐）
   - 点击右上角 "+" 按钮
   - 保持"自然语言输入"开关开启
   - 输入提醒内容，如 "每两周换被罩"
   - 系统自动识别并显示解析结果
   - 点击"添加"

2. **手动输入方式**
   - 点击右上角 "+" 按钮
   - 关闭"自然语言输入"开关
   - 填写标题、周期间隔和开始时间
   - 点击"添加"

3. **使用 Siri**
   - 对 Siri 说："添加定时提醒每两周换被罩"
   - Siri 会自动创建提醒

### 管理提醒

- **完成提醒**：左滑提醒条目，点击"完成"
- **删除提醒**：右滑提醒条目，点击"删除"
- **启用/禁用**：点击提醒右侧的开关
- **延后提醒**：在通知弹出时点击"延后1天"

### 通知操作

当提醒时间到达时：
- 收到系统通知
- 可以选择"完成"或"延后1天"
- 完成后自动计算下次提醒时间

## 系统要求

- iOS 17.0 或更高版本
- iPhone 或 iPad

## 构建和运行

1. 克隆仓库
```bash
git clone https://github.com/lnwu/regular-reminder.git
cd regular-reminder
```

2. 打开 Xcode 项目
```bash
open RegularReminderApp/RegularReminder.xcodeproj
```

3. 选择目标设备（模拟器或真机）

4. 点击运行按钮（⌘R）

## 权限说明

应用需要以下权限：
- **通知权限**：用于发送定时提醒通知

首次启动时会请求这些权限。

## 隐私保护

- 所有数据存储在本地设备
- 不会上传任何个人信息到服务器
- 不收集用户隐私数据

## 开发计划

未来可能添加的功能：
- [ ] iCloud 同步
- [ ] Widget 小组件
- [ ] Apple Watch 支持
- [ ] 提醒分类和标签
- [ ] 提醒历史记录
- [ ] 自定义通知声音
- [ ] 提醒统计和分析

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 联系方式

如有问题或建议，请通过 GitHub Issues 联系。