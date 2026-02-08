import Foundation
import SwiftUI

/// Represents a periodic reminder
struct Reminder: Identifiable, Codable {
    var id: UUID
    var title: String
    var startDate: Date
    var intervalType: IntervalType
    var intervalValue: Int
    var isEnabled: Bool
    var lastCompletedDate: Date?
    var nextReminderDate: Date
    
    init(id: UUID = UUID(), 
         title: String, 
         startDate: Date = Date(), 
         intervalType: IntervalType, 
         intervalValue: Int,
         isEnabled: Bool = true) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.intervalType = intervalType
        self.intervalValue = intervalValue
        self.isEnabled = isEnabled
        self.lastCompletedDate = nil
        self.nextReminderDate = startDate
    }
    
    mutating func calculateNextReminderDate() {
        let calendar = Calendar.current
        let baseDate = lastCompletedDate ?? startDate
        
        switch intervalType {
        case .days:
            nextReminderDate = calendar.date(byAdding: .day, value: intervalValue, to: baseDate) ?? baseDate
        case .weeks:
            nextReminderDate = calendar.date(byAdding: .weekOfYear, value: intervalValue, to: baseDate) ?? baseDate
        case .months:
            nextReminderDate = calendar.date(byAdding: .month, value: intervalValue, to: baseDate) ?? baseDate
        case .years:
            nextReminderDate = calendar.date(byAdding: .year, value: intervalValue, to: baseDate) ?? baseDate
        }
    }
    
    mutating func complete() {
        lastCompletedDate = Date()
        calculateNextReminderDate()
    }
    
    mutating func snooze(by days: Int) {
        let calendar = Calendar.current
        nextReminderDate = calendar.date(byAdding: .day, value: days, to: Date()) ?? Date()
    }
}

enum IntervalType: String, Codable, CaseIterable {
    case days = "天"
    case weeks = "周"
    case months = "月"
    case years = "年"
    
    var localizedName: String {
        return self.rawValue
    }
}
