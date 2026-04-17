import Foundation

extension UserDefaults {
    /// Gets the first reminder time set during onboarding
    var firstReminderTime: (hour: Int, minute: Int) {
        let hour = integer(forKey: "firstReminderHour")
        let minute = integer(forKey: "firstReminderMinute")
        return (hour: hour, minute: minute)
    }
    
    /// Gets the second reminder time set during onboarding
    var secondReminderTime: (hour: Int, minute: Int) {
        let hour = integer(forKey: "secondReminderHour")
        let minute = integer(forKey: "secondReminderMinute")
        return (hour: hour, minute: minute)
    }
    
    /// Formats a time tuple as a readable string
    static func formatTime(hour: Int, minute: Int) -> String {
        let date = Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
