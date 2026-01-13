# 贡献指南 (Contributing Guide)

感谢您对定时提醒项目的关注！我们欢迎任何形式的贡献。

## 如何贡献

### 报告 Bug

如果您发现了 bug，请：

1. 检查 [Issues](https://github.com/lnwu/regular-reminder/issues) 是否已有相关报告
2. 如果没有，创建新的 Issue，包含：
   - 清晰的标题
   - 详细的问题描述
   - 复现步骤
   - 期望行为
   - 实际行为
   - iOS 版本和设备信息
   - 截图（如适用）

### 提出功能建议

我们欢迎新的想法！请：

1. 创建新的 Issue，标记为 `enhancement`
2. 描述您的建议：
   - 功能的用途
   - 使用场景
   - 可能的实现方式（可选）

### 提交代码

#### 开发环境设置

1. **Fork 仓库**
   ```bash
   # 在 GitHub 上点击 Fork 按钮
   ```

2. **克隆您的 Fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/regular-reminder.git
   cd regular-reminder
   ```

3. **打开项目**
   ```bash
   open RegularReminderApp/RegularReminder.xcodeproj
   ```

4. **创建分支**
   ```bash
   git checkout -b feature/your-feature-name
   ```

#### 代码规范

**Swift 代码风格：**

- 使用 4 个空格缩进（不使用 Tab）
- 遵循 [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- 使用有意义的变量和函数名
- 添加必要的注释，特别是公共 API

**示例：**

```swift
// ✅ 好的命名
func calculateNextReminderDate() -> Date {
    // 实现
}

// ❌ 不好的命名
func calc() -> Date {
    // 实现
}

// ✅ 好的注释
/// 计算下一次提醒的日期
/// - Returns: 基于当前设置计算出的下次提醒日期
func calculateNextReminderDate() -> Date {
    // 实现
}
```

**SwiftUI 视图：**

```swift
// ✅ 清晰的视图结构
struct ContentView: View {
    var body: some View {
        NavigationStack {
            mainContent
                .navigationTitle("定时提醒")
                .toolbar {
                    toolbarContent
                }
        }
    }
    
    private var mainContent: some View {
        // 主要内容
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // 工具栏内容
    }
}
```

#### 提交规范

**提交信息格式：**

```
<type>: <subject>

<body>

<footer>
```

**类型 (type)：**
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动

**示例：**

```bash
feat: 添加编辑提醒功能

允许用户编辑已有的提醒，包括标题、周期和开始时间。

Closes #123
```

```bash
fix: 修复自然语言解析中文数字的问题

修复了无法识别"每三天"中的"三"字的问题。

Fixes #456
```

#### Pull Request 流程

1. **确保代码质量**
   - 代码通过编译
   - 没有警告
   - 功能正常工作
   - 添加了必要的测试（如适用）

2. **更新文档**
   - 如果添加了新功能，更新 README.md
   - 更新 USAGE_GUIDE.md（如适用）
   - 添加代码注释

3. **创建 Pull Request**
   - 清晰的标题
   - 详细的描述：
     - 更改的内容
     - 为什么需要这个更改
     - 如何测试
   - 关联相关 Issue
   - 添加截图（UI 更改）

4. **代码审查**
   - 响应审查意见
   - 进行必要的修改
   - 保持讨论专业和友好

5. **合并**
   - PR 被批准后将被合并
   - 删除您的分支（可选）

## 开发指南

### 项目结构

```
RegularReminderApp/
├── Models/          # 数据模型
├── Views/           # UI 视图
├── Services/        # 业务逻辑服务
├── Intents/         # Siri 集成
└── Assets.xcassets/ # 资源文件
```

### 添加新功能

1. **在 Models 中定义数据结构**
   ```swift
   struct YourModel: Codable {
       // 属性
   }
   ```

2. **在 Services 中实现业务逻辑**
   ```swift
   class YourService {
       // 方法
   }
   ```

3. **在 Views 中创建 UI**
   ```swift
   struct YourView: View {
       var body: some View {
           // UI
       }
   }
   ```

4. **添加测试**（如适用）
   ```swift
   class YourTests: XCTestCase {
       func testYourFeature() {
           // 测试
       }
   }
   ```

### 常见任务

#### 添加新的时间间隔类型

1. 在 `IntervalType` 枚举中添加新类型
2. 更新 `calculateNextReminderDate()` 方法
3. 更新自然语言解析器
4. 添加本地化字符串

#### 添加新的通知操作

1. 在 `NotificationService` 中定义新操作
2. 更新 `setupNotificationCategories()`
3. 在 `ContentView` 中处理新操作
4. 更新 UI 和文档

### 测试

#### 运行测试

```bash
# 在 Xcode 中
⌘ + U
```

#### 添加测试

```swift
import XCTest
@testable import RegularReminder

class ReminderTests: XCTestCase {
    func testReminderCreation() {
        let reminder = Reminder(
            title: "测试",
            intervalType: .days,
            intervalValue: 7
        )
        XCTAssertEqual(reminder.title, "测试")
        XCTAssertEqual(reminder.intervalValue, 7)
    }
}
```

### 调试技巧

1. **使用 Xcode 调试器**
   - 设置断点
   - 使用 LLDB 命令

2. **SwiftUI 预览**
   - 使用 `#Preview` 快速迭代 UI
   - 测试不同的数据状态

3. **日志输出**
   ```swift
   print("Debug: \(someValue)")
   ```

## 本地化

### 添加新的本地化字符串

1. 在 `zh-Hans.lproj/Localizable.strings` 中添加：
   ```
   "your_key" = "你的文本";
   ```

2. 在代码中使用：
   ```swift
   Text(NSLocalizedString("your_key", comment: ""))
   ```

### 支持新语言

1. 在 Xcode 中添加新语言
2. 创建对应的 `.lproj` 目录
3. 翻译所有字符串

## 行为准则

### 我们的承诺

- 尊重所有贡献者
- 欢迎不同观点
- 接受建设性批评
- 关注项目最佳利益

### 不可接受的行为

- 骚扰或歧视性言论
- 人身攻击
- 发布他人隐私信息
- 其他不专业行为

## 许可证

通过贡献代码，您同意您的贡献将在 MIT 许可证下发布。

## 问题？

如有任何问题，请：
- 创建 Issue 提问
- 查看现有文档
- 联系维护者

## 致谢

感谢所有贡献者的付出！

您的贡献使这个项目变得更好。🎉
