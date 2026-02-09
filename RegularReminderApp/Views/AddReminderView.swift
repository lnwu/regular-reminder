import SwiftUI

struct AddReminderView: View {
    @Environment(ReminderStore.self) private var reminderStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var inputText = ""
    @State private var useNaturalLanguage = true
    
    // Manual input fields
    @State private var title = ""
    @State private var intervalValue = 1
    @State private var intervalType: IntervalType = .days
    @State private var startDate = Date()
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var parsedReminder: Reminder?
    
    private let parser = NaturalLanguageParser()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(NSLocalizedString("natural_language_input", comment: ""), isOn: $useNaturalLanguage)
                        .onChange(of: useNaturalLanguage) { _, _ in
                            inputText = ""
                            title = ""
                            parsedReminder = nil
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
            .navigationTitle(NSLocalizedString("add_reminder", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("add", comment: "")) {
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
            .onChange(of: inputText) { _, newValue in
                parsedReminder = parser.parseReminder(from: newValue)
            }
        }
    }
    
    private var naturalLanguageSection: some View {
        Section {
            TextField(NSLocalizedString("placeholder_reminder", comment: ""), text: $inputText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            if !inputText.isEmpty, let reminder = parsedReminder {
                ParseResultCard(reminder: reminder)
            }
        } header: {
            Text(NSLocalizedString("describe_reminder", comment: ""))
        } footer: {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(NSLocalizedString("example", comment: "")):")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("• \(NSLocalizedString("example_1", comment: ""))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("• \(NSLocalizedString("example_2", comment: ""))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("• \(NSLocalizedString("example_3", comment: ""))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("• \(NSLocalizedString("example_4", comment: ""))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var manualInputSection: some View {
        Group {
            Section {
                TextField(NSLocalizedString("reminder_title", comment: ""), text: $title)
            } header: {
                Text(NSLocalizedString("title", comment: ""))
            }
            
            Section {
                Stepper("\(intervalValue)", value: $intervalValue, in: 1...365)
                
                Picker(NSLocalizedString("interval_unit", comment: ""), selection: $intervalType) {
                    ForEach(IntervalType.allCases, id: \.self) { type in
                        Text(type.localizedName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text(NSLocalizedString("repeat_period", comment: ""))
            }
            
            Section {
                DatePicker(NSLocalizedString("start_date", comment: ""), selection: $startDate)
            } header: {
                Text(NSLocalizedString("start_date", comment: ""))
            }
        }
    }
    
    private var canAddReminder: Bool {
        if useNaturalLanguage {
            return !inputText.isEmpty && parsedReminder != nil
        } else {
            return !title.isEmpty
        }
    }
    
    private func addReminder() {
        let reminder: Reminder
        
        if useNaturalLanguage {
            guard let validReminder = parsedReminder else {
                alertMessage = NSLocalizedString("parse_failed", comment: "")
                showingAlert = true
                return
            }
            reminder = validReminder
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

// MARK: - Extracted Views

/// 解析结果卡片（支持 Liquid Glass 效果）
struct ParseResultCard: View {
    let reminder: Reminder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text(NSLocalizedString("parse_success", comment: ""))
                    .font(.subheadline)
                    .foregroundStyle(.green)
            }
            
            Divider()
            
            HStack {
                Text("\(NSLocalizedString("title", comment: "")):")
                    .foregroundStyle(.secondary)
                Text(reminder.title)
            }
            
            HStack {
                Text("\(NSLocalizedString("period", comment: "")):")
                    .foregroundStyle(.secondary)
                Text("\(NSLocalizedString("every", comment: ""))\(reminder.intervalValue)\(reminder.intervalType.localizedName)")
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.1))
            }
        }
    }
}

#Preview {
    AddReminderView()
        .environment(ReminderStore())
}
