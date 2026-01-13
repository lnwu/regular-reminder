# 功能演示 (Feature Demonstration)

## 主要功能流程图

### 1. 添加提醒流程

```
开始
  │
  ↓
点击 + 按钮
  │
  ↓
选择输入方式
  │
  ├─→ 自然语言输入
  │   │
  │   ↓
  │   输入："每两周换被罩"
  │   │
  │   ↓
  │   解析器分析
  │   │
  │   ├─→ 识别成功 ✅
  │   │   │
  │   │   ↓
  │   │   显示预览：
  │   │   - 标题: 换被罩
  │   │   - 周期: 每2周
  │   │
  │   └─→ 识别失败 ❌
  │       │
  │       ↓
  │       切换到手动输入
  │
  └─→ 手动输入
      │
      ↓
      填写表单：
      - 标题
      - 间隔数值
      - 间隔单位
      - 开始时间
  │
  ↓
点击"添加"
  │
  ↓
保存到本地
  │
  ↓
调度通知
  │
  ↓
显示在列表中
  │
  ↓
完成
```

### 2. 接收提醒流程

```
到达提醒时间
  │
  ↓
系统发送通知
  │
  ↓
用户收到通知
  │
  ├─→ 点击"完成" ✅
  │   │
  │   ↓
  │   更新完成时间
  │   │
  │   ↓
  │   计算下次提醒
  │   │
  │   ↓
  │   调度新通知
  │   │
  │   ↓
  │   更新列表显示
  │
  ├─→ 点击"延后1天" ⏰
  │   │
  │   ↓
  │   设置明天提醒
  │   │
  │   ↓
  │   调度延后通知
  │   │
  │   ↓
  │   更新列表显示
  │
  └─→ 忽略通知 🔕
      │
      ↓
      保持未完成状态
      │
      ↓
      可在应用内处理
```

### 3. Siri 添加提醒流程

```
用户说话
  │
  ↓
"添加定时提醒每两周换被罩"
  │
  ↓
Siri 识别语音
  │
  ↓
调用 AddReminderIntent
  │
  ↓
解析提醒内容
  │
  ├─→ 解析成功 ✅
  │   │
  │   ↓
  │   创建提醒对象
  │   │
  │   ↓
  │   保存到本地
  │   │
  │   ↓
  │   调度通知
  │   │
  │   ↓
  │   Siri 反馈：
  │   "已添加提醒：换被罩，每2周"
  │
  └─→ 解析失败 ❌
      │
      ↓
      Siri 反馈：
      "无法识别提醒内容，请尝试说：每两周换被罩"
```

## 界面层级结构

```
RegularReminderApp
│
├── ContentView (主界面)
│   │
│   ├── NavigationStack
│   │   │
│   │   ├── Title: "定时提醒"
│   │   │
│   │   ├── Toolbar
│   │   │   └── + 按钮
│   │   │
│   │   └── Body
│   │       │
│   │       ├── 空状态视图
│   │       │   ├── 🔔 图标
│   │       │   ├── "暂无提醒"
│   │       │   └── "点击 + 添加新的定时提醒"
│   │       │
│   │       └── 提醒列表
│   │           │
│   │           └── ReminderRow × N
│   │               ├── 标题
│   │               ├── 🕐 周期
│   │               ├── 🔔 下次时间
│   │               └── 🔄 开关
│   │
│   └── Sheet: AddReminderView
│
└── AddReminderView (添加提醒界面)
    │
    ├── NavigationStack
    │   │
    │   ├── Title: "添加提醒"
    │   │
    │   ├── Toolbar
    │   │   ├── "取消" (左)
    │   │   └── "添加" (右)
    │   │
    │   └── Form
    │       │
    │       ├── Section: 输入方式
    │       │   └── Toggle: "自然语言输入"
    │       │
    │       ├── Section: 自然语言
    │       │   ├── TextField
    │       │   ├── 解析反馈
    │       │   └── 示例列表
    │       │
    │       └── Section: 手动输入
    │           ├── TextField: 标题
    │           ├── Stepper: 间隔数值
    │           ├── Picker: 间隔单位
    │           └── DatePicker: 开始时间
    │
    └── Alert: 提示信息
```

## 数据流向图

```
用户操作
  │
  ↓
SwiftUI View
  │
  ↓
@EnvironmentObject
  │
  ↓
ReminderStore (@Published)
  │
  ├──→ UserDefaults (持久化)
  │    │
  │    └──→ 磁盘存储
  │
  └──→ NotificationService
       │
       └──→ UNUserNotificationCenter
            │
            └──→ iOS 系统通知
                 │
                 └──→ 定时触发通知
```

## 状态管理

```
ReminderStore (Single Source of Truth)
  │
  ├── @Published reminders: [Reminder]
  │   │
  │   ├── 添加 → addReminder()
  │   │   └── 触发 UI 更新
  │   │
  │   ├── 更新 → updateReminder()
  │   │   └── 触发 UI 更新
  │   │
  │   ├── 删除 → deleteReminder()
  │   │   └── 触发 UI 更新
  │   │
  │   ├── 完成 → completeReminder()
  │   │   └── 触发 UI 更新
  │   │
  │   └── 延后 → snoozeReminder()
  │       └── 触发 UI 更新
  │
  └── 自动 UI 刷新 (SwiftUI)
      │
      ├── ContentView
      ├── ReminderRow
      └── AddReminderView
```

## 通知系统架构

```
Reminder 对象
  │
  ↓
计算 nextReminderDate
  │
  ↓
NotificationService
  │
  ├── 创建 UNMutableNotificationContent
  │   ├── 标题: "定时提醒"
  │   ├── 正文: reminder.title
  │   ├── 分类: REMINDER_CATEGORY
  │   └── 操作: [完成, 延后1天]
  │
  ├── 创建 UNTimeIntervalNotificationTrigger
  │   └── timeInterval = nextDate - now
  │
  └── 创建 UNNotificationRequest
      │
      ↓
  UNUserNotificationCenter
      │
      ↓
  iOS 系统调度
      │
      ↓
  到时触发通知
```

## 自然语言解析流程

```
输入: "每两周换被罩"
  │
  ↓
查找关键词: "周"
  │
  ↓
分割字符串
  ├── 之前: "每两"
  └── 之后: "换被罩"
  │
  ↓
提取数字
  │
  ├── 尝试阿拉伯数字: Int("两") → nil
  ├── 尝试中文数字: "两" → 2 ✅
  │
  ↓
确定间隔类型: "周" → .weeks
  │
  ↓
提取标题: "换被罩"
  │
  ↓
创建 Reminder
  ├── intervalValue: 2
  ├── intervalType: .weeks
  └── title: "换被罩"
  │
  ↓
返回结果 ✅
```

## 应用生命周期

```
应用启动
  │
  ├─→ RegularReminderApp.init()
  │   ├── 设置通知分类
  │   ├── 请求通知权限
  │   └── 设置通知代理
  │
  ├─→ ReminderStore.init()
  │   └── 从 UserDefaults 加载数据
  │
  └─→ ContentView.body
      └── 显示 UI
  │
  ↓
用户交互...
  │
  ↓
应用进入后台
  │
  ├─→ 保存状态
  └─→ 通知继续运行 (系统管理)
  │
  ↓
应用恢复前台
  │
  └─→ onChange(of: scenePhase)
      └── 刷新通知
```

## 安全和隐私

```
用户数据
  │
  ├─→ 本地存储
  │   │
  │   ├── UserDefaults
  │   │   ├── 应用沙盒
  │   │   └── 设备本地
  │   │
  │   └── 通知数据
  │       └── 系统管理
  │
  ├─→ 不上传云端 ✅
  ├─→ 不收集统计 ✅
  └─→ 不共享第三方 ✅
```

---

这些流程图和架构图展示了应用的核心功能和技术实现。所有流程都遵循 iOS 最佳实践，确保用户体验流畅自然。
