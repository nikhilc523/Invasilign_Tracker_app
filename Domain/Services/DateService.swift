import Foundation

enum DateService {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar
    }()

    static func startOfDay(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    static func isToday(_ date: Date, now: Date = Date()) -> Bool {
        calendar.isDate(date, inSameDayAs: now)
    }

    static func isFutureDay(_ date: Date, now: Date = Date()) -> Bool {
        startOfDay(for: date) > startOfDay(for: now)
    }

    static func addDays(_ days: Int, to date: Date) -> Date {
        calendar.date(byAdding: .day, value: days, to: startOfDay(for: date)) ?? date
    }

    static func daysBetween(_ start: Date, _ end: Date) -> Int {
        let components = calendar.dateComponents([.day], from: startOfDay(for: start), to: startOfDay(for: end))
        return components.day ?? 0
    }

    static func weekDates(containing date: Date = Date()) -> [Date] {
        let weekday = calendar.component(.weekday, from: date)
        let start = addDays(-(weekday - 1), to: date)
        return (0..<7).map { addDays($0, to: start) }
    }

    static func monthGrid(year: Int, month: Int) -> [Date?] {
        var comps = DateComponents()
        comps.timeZone = calendar.timeZone // Align to the system calendar's timezone
        comps.year = year
        comps.month = month
        comps.day = 1
        comps.hour = 0
        comps.minute = 0
        comps.second = 0

        guard let first = calendar.date(from: comps),
              let dayRange = calendar.range(of: .day, in: .month, for: first) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: first)
        var cells: [Date?] = Array(repeating: nil, count: max(0, firstWeekday - 1))
        for day in dayRange {
            var c = comps
            c.day = day
            cells.append(calendar.date(from: c))
        }
        return cells
    }
}
