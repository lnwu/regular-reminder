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

### 前置要求

在开始之前，请确保您的 Mac 电脑满足以下要求：

1. **macOS 系统**：macOS 13.0 (Ventura) 或更高版本
2. **Xcode**：Xcode 15.0 或更高版本（免费）
3. **Apple ID**：用于在真机上运行（模拟器不需要）

### 安装 Xcode

如果您还没有安装 Xcode：

1. 打开 Mac 上的 **App Store**
2. 搜索 "Xcode"
3. 点击"获取"或"下载"按钮（大约 7-12 GB，下载可能需要一些时间）
4. 安装完成后，打开 Xcode 一次，接受许可协议
5. 等待 Xcode 安装必要的组件

### 详细步骤：在本地启动应用

#### 第一步：获取项目代码

打开 Mac 的 **终端** 应用（可以在 Spotlight 中搜索"终端"），然后输入以下命令：

```bash
# 1. 克隆项目到本地（如果还没有克隆）
git clone https://github.com/lnwu/regular-reminder.git

# 2. 进入项目目录
cd regular-reminder
```

#### 第二步：打开 Xcode 项目

在终端中继续输入：

```bash
# 打开 Xcode 项目
open RegularReminderApp/RegularReminder.xcodeproj
```

或者，您也可以：
- 打开 Xcode 应用
- 选择 "File" > "Open"（文件 > 打开）
- 导航到项目文件夹，选择 `RegularReminder.xcodeproj` 文件
- 点击"Open"（打开）

#### 第三步：选择运行目标

在 Xcode 窗口顶部，您会看到一个设备选择器：

1. 点击设备选择器（默认可能显示 "Any iOS Device"）
2. 选择一个 iPhone 模拟器，例如：
   - **iPhone 15 Pro**（推荐）
   - **iPhone 14**
   - **iPhone SE (3rd generation)**

**提示**：
- 模拟器：用于在 Mac 上测试，无需真实 iPhone
- 真机：需要 Apple ID 登录，并信任开发者证书

#### 第四步：运行应用

**方式 1**：使用快捷键
- 按下 `⌘ + R`（Command + R）

**方式 2**：使用按钮
- 点击 Xcode 左上角的 **▶️ 播放按钮**（Run 按钮）

**方式 3**：使用菜单
- 选择菜单栏的 "Product" > "Run"（产品 > 运行）

#### 第五步：等待构建和启动

1. Xcode 会开始编译项目（第一次可能需要 1-2 分钟）
2. 编译成功后，模拟器会自动启动
3. 应用会在模拟器中打开
4. 首次运行时，应用会请求通知权限，请点击"允许"

### 在真机上运行（可选）

如果您想在真实的 iPhone 或 iPad 上运行：

1. **连接设备**：使用 USB 线将 iPhone/iPad 连接到 Mac
2. **信任设备**：
   - 在 iPhone 上点击"信任此电脑"
   - 如果需要，在 Mac 上也点击"信任"
3. **配置签名**：
   - 在 Xcode 中，点击项目导航器中的项目名称（蓝色图标）
   - 选择 "Signing & Capabilities"（签名与功能）
   - 在 "Team" 下拉菜单中选择您的 Apple ID
   - 如果没有，点击 "Add Account"（添加账户）登录您的 Apple ID
4. **选择设备**：在设备选择器中选择您的 iPhone/iPad
5. **运行**：按 `⌘ + R` 运行
6. **信任开发者**（首次运行）：
   - 在 iPhone 上打开 "设置" > "通用" > "VPN与设备管理"
   - 点击您的 Apple ID
   - 点击"信任"

### 常见问题排查

#### 问题 1：Xcode 提示 "Build Failed"（构建失败）

**解决方法**：
- 确保 Xcode 版本是 15.0 或更高
- 清理构建：选择 "Product" > "Clean Build Folder"（产品 > 清理构建文件夹）
- 重新运行：按 `⌘ + R`

#### 问题 2：模拟器无法启动

**解决方法**：
- 关闭模拟器，然后重新运行
- 重启 Xcode
- 检查 Mac 的存储空间是否充足（至少需要 10GB 可用空间）

#### 问题 3：真机上显示 "Untrusted Developer"（不受信任的开发者）

**解决方法**：
- 在 iPhone 上打开 "设置" > "通用" > "VPN与设备管理"
- 找到您的 Apple ID 或开发者证书
- 点击"信任"

#### 问题 4：提示需要付费的 Apple Developer Program

**说明**：
- 在模拟器上运行：**完全免费**，不需要付费
- 在真机上测试：**免费**，只需 Apple ID
- 发布到 App Store：需要加入 Apple Developer Program（每年 $99）

### 使用模拟器的技巧

运行应用后，您可以在模拟器中：

1. **测试通知**：
   - 添加一个提醒
   - 将开始时间设置为 1 分钟后
   - 等待通知出现

2. **测试深色模式**：
   - 在模拟器菜单选择 "Features" > "Toggle Appearance"
   - 查看应用在浅色/深色模式下的显示效果

3. **测试不同设备**：
   - 停止应用（⌘ + .）
   - 切换到不同的模拟器（如 iPad）
   - 重新运行查看适配效果

### 下一步

应用成功运行后：
- 尝试添加第一个提醒："每两周换被罩"
- 查看 [使用指南](USAGE_GUIDE.md) 了解所有功能
- 查看 [架构文档](ARCHITECTURE.md) 了解技术实现

### 需要帮助？

如果遇到其他问题：
1. 查看 [常见问题](USAGE_GUIDE.md#常见问题)
2. 提交 [GitHub Issue](https://github.com/lnwu/regular-reminder/issues)
3. 确保描述您的：
   - macOS 版本
   - Xcode 版本
   - 错误信息截图

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