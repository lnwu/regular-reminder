import Foundation

/// Parses natural language input to create reminders
class NaturalLanguageParser {
    
    /// Attempts to parse a natural language string into a Reminder
    /// Examples:
    /// - "每两周换被罩"
    /// - "每3天浇花"
    /// - "每个月还信用卡"
    /// - "每年体检"
    func parseReminder(from text: String) -> Reminder? {
        // Remove extra whitespace
        let trimmedText = text.trimmingCharacters(in: .whitespaces)
        
        // Try to extract interval information
        if let (intervalValue, intervalType, title) = extractComponents(from: trimmedText) {
            return Reminder(
                title: title,
                startDate: Date(),
                intervalType: intervalType,
                intervalValue: intervalValue
            )
        }
        
        return nil
    }
    
    private func extractComponents(from text: String) -> (Int, IntervalType, String)? {
        // Pattern: "每" + number (optional) + interval type + title
        let patterns: [(String, IntervalType)] = [
            ("天", .days),
            ("周", .weeks),
            ("星期", .weeks),
            ("个月", .months),
            ("月", .months),
            ("年", .years)
        ]
        
        for (keyword, intervalType) in patterns {
            if let range = text.range(of: keyword) {
                let beforeKeyword = String(text[..<range.lowerBound])
                let afterKeyword = String(text[range.upperBound...])
                
                // Extract number
                var intervalValue = 1
                
                // Check for "每两" or "每三" pattern
                if beforeKeyword.contains("每") {
                    let numberPart = beforeKeyword.replacingOccurrences(of: "每", with: "")
                    intervalValue = extractNumber(from: numberPart) ?? 1
                }
                
                // Extract title (everything after the interval type)
                let title = afterKeyword.trimmingCharacters(in: .whitespaces)
                
                // If no title provided, use a default
                let finalTitle = title.isEmpty ? "提醒" : title
                
                return (intervalValue, intervalType, finalTitle)
            }
        }
        
        // If no pattern matched, return nil
        return nil
    }
    
    private func extractNumber(from text: String) -> Int? {
        // Try to parse as digit
        if let number = Int(text) {
            return number
        }
        
        // Try to parse Chinese number characters using exact match
        let chineseNumbers: [String: Int] = [
            "一": 1, "两": 2, "二": 2, "三": 3, "四": 4, "五": 5,
            "六": 6, "七": 7, "八": 8, "九": 9, "十": 10,
            "十一": 11, "十二": 12, "十三": 13, "十四": 14, "十五": 15,
            "十六": 16, "十七": 17, "十八": 18, "十九": 19, "二十": 20
        ]
        
        return chineseNumbers[text]
    }
    }
}
