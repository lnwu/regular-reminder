import SwiftUI

struct AddReminderView: View {
    @EnvironmentObject var reminderStore: ReminderStore
    @Environment(\.dismiss) var dismiss
    
    @State private var inputText = ""
    @State private var useNaturalLanguage = true
    
    // Manual input fields
    @State private var title = ""
    @State private var intervalValue = 1
    @State private var intervalType: IntervalType = .days
    @State private var startDate = Date()
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let parser = NaturalLanguageParser()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("自然语言输入", isOn: $useNaturalLanguage)
                        .onChange(of: useNaturalLanguage) { _, _ in
                            inputText = ""
                            title = ""
                        }
                } header: {
                    Text("输入方式")
                }
                
                if useNaturalLanguage {
                    naturalLanguageSection
                } else {
                    manualInputSection
                }
            }
            .navigationTitle("添加提醒")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加") {
                        addReminder()
                    }
                    .disabled(!canAddReminder)
                }
            }
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var naturalLanguageSection: some View {
        Section {
            TextField("例如: 每两周换被罩", text: $inputText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            if !inputText.isEmpty, let parsedReminder = parser.parseReminder(from: inputText) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("识别成功")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("标题:")
                            .foregroundColor(.secondary)
                        Text(parsedReminder.title)
                    }
                    
                    HStack {
                        Text("周期:")
                            .foregroundColor(.secondary)
                        Text("每\(parsedReminder.intervalValue)\(parsedReminder.intervalType.localizedName)")
                    }
                }
                .padding(.vertical, 8)
            }
        } header: {
            Text("描述提醒")
        } footer: {
            VStack(alignment: .leading, spacing: 4) {
                Text("示例:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("• 每两周换被罩")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("• 每3天浇花")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("• 每个月还信用卡")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("• 每年体检")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var manualInputSection: some View {
        Group {
            Section {
                TextField("提醒标题", text: $title)
            } header: {
                Text("标题")
            }
            
            Section {
                Stepper("\(intervalValue)", value: $intervalValue, in: 1...365)
                
                Picker("间隔单位", selection: $intervalType) {
                    ForEach(IntervalType.allCases, id: \.self) { type in
                        Text(type.localizedName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("重复周期")
            }
            
            Section {
                DatePicker("开始时间", selection: $startDate)
            } header: {
                Text("开始时间")
            }
        }
    }
    
    private var canAddReminder: Bool {
        if useNaturalLanguage {
            return !inputText.isEmpty && parser.parseReminder(from: inputText) != nil
        } else {
            return !title.isEmpty
        }
    }
    
    private func addReminder() {
        let reminder: Reminder
        
        if useNaturalLanguage {
            guard let parsedReminder = parser.parseReminder(from: inputText) else {
                alertMessage = "无法识别输入的内容，请尝试其他格式"
                showingAlert = true
                return
            }
            reminder = parsedReminder
        } else {
            reminder = Reminder(
                title: title,
                startDate: startDate,
                intervalType: intervalType,
                intervalValue: intervalValue
            )
        }
        
        reminderStore.addReminder(reminder)
        dismiss()
    }
}

#Preview {
    AddReminderView()
        .environmentObject(ReminderStore())
}
