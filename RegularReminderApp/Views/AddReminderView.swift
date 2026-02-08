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
                    Toggle(NSLocalizedString("natural_language_input", comment: ""), isOn: $useNaturalLanguage)
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
        }
    }
    
    private var naturalLanguageSection: some View {
        Section {
            TextField(NSLocalizedString("placeholder_reminder", comment: ""), text: $inputText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            if !inputText.isEmpty, let parsedReminder = parser.parseReminder(from: inputText) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(NSLocalizedString("parse_success", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("\(NSLocalizedString("title", comment: "")):")
                            .foregroundColor(.secondary)
                        Text(parsedReminder.title)
                    }
                    
                    HStack {
                        Text("\(NSLocalizedString("period", comment: "")):")
                            .foregroundColor(.secondary)
                        Text("\(NSLocalizedString("every", comment: ""))\(parsedReminder.intervalValue)\(parsedReminder.intervalType.localizedName)")
                    }
                }
                .padding(.vertical, 8)
            }
        } header: {
            Text(NSLocalizedString("describe_reminder", comment: ""))
        } footer: {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(NSLocalizedString("example", comment: "")):")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("• \(NSLocalizedString("example_1", comment: ""))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("• \(NSLocalizedString("example_2", comment: ""))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("• \(NSLocalizedString("example_3", comment: ""))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("• \(NSLocalizedString("example_4", comment: ""))")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
            return !inputText.isEmpty && parser.parseReminder(from: inputText) != nil
        } else {
            return !title.isEmpty
        }
    }
    
    private func addReminder() {
        let reminder: Reminder
        
        if useNaturalLanguage {
            guard let parsedReminder = parser.parseReminder(from: inputText) else {
                alertMessage = NSLocalizedString("parse_failed", comment: "")
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
