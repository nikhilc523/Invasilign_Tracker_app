import XCTest
@testable import InvisalignTracker

final class TrackerCalculatorTests: XCTestCase {
    func testRemovalMinutesHandlesCrossMidnightSessions() {
        let calendar = DateService.calendar
        let start = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10, hour: 23, minute: 30))!
        let end = calendar.date(from: DateComponents(year: 2026, month: 2, day: 11, hour: 0, minute: 30))!
        let session = RemovalSession(id: UUID(), startTime: start, endTime: end)

        let dayOne = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10))!
        let dayTwo = calendar.date(from: DateComponents(year: 2026, month: 2, day: 11))!

        XCTAssertEqual(TrackerCalculator.removalMinutes(on: dayOne, sessions: [session], now: end), 30, accuracy: 0.01)
        XCTAssertEqual(TrackerCalculator.removalMinutes(on: dayTwo, sessions: [session], now: end), 30, accuracy: 0.01)
    }

    func testWearMinutesSubtractsRemovalFromElapsedDay() {
        let calendar = DateService.calendar
        let day = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10))!
        let sessionStart = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10, hour: 8, minute: 0))!
        let sessionEnd = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10, hour: 9, minute: 0))!
        let now = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10, hour: 12, minute: 0))!

        let session = RemovalSession(id: UUID(), startTime: sessionStart, endTime: sessionEnd)
        XCTAssertEqual(TrackerCalculator.wearMinutes(on: day, sessions: [session], now: now), 11 * 60, accuracy: 0.01)
    }

    func testStatusPassWarnFailThresholds() {
        let calendar = DateService.calendar
        let day = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10))!

        let pass = mockSession(day: day, outMinutes: 60)
        let warn = mockSession(day: day, outMinutes: 400)
        let fail = mockSession(day: day, outMinutes: 700)

        XCTAssertEqual(TrackerCalculator.status(for: day, sessions: [pass], targetMinutes: 22 * 60, graceMinutes: 5, now: DateService.addDays(1, to: day)), .pass)
        XCTAssertEqual(TrackerCalculator.status(for: day, sessions: [warn], targetMinutes: 22 * 60, graceMinutes: 5, now: DateService.addDays(1, to: day)), .warn)
        XCTAssertEqual(TrackerCalculator.status(for: day, sessions: [fail], targetMinutes: 22 * 60, graceMinutes: 5, now: DateService.addDays(1, to: day)), .fail)
    }

    func testTrayLifeShortfallAccumulatesPerDayDeficit() {
        let calendar = DateService.calendar
        let trayStart = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10))!
        let tray = Tray(id: UUID(), number: 1, startDate: trayStart, plannedDays: 2)
        let now = calendar.date(from: DateComponents(year: 2026, month: 2, day: 12, hour: 8))!

        let dayOneOutStart = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10, hour: 8))!
        let dayOneOutEnd = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10, hour: 12))!
        let session = RemovalSession(id: UUID(), startTime: dayOneOutStart, endTime: dayOneOutEnd)

        let shortfall = TrackerCalculator.trayLifeShortfallMinutes(
            for: tray,
            sessions: [session],
            targetMinutes: 22 * 60,
            now: now
        )

        XCTAssertEqual(shortfall, 120, accuracy: 0.01)
    }

    func testTrayOneDayExtensionEligibilityRequiresCompletionAndThreshold() {
        let calendar = DateService.calendar
        let completedTrayStart = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10))!
        let completedTray = Tray(id: UUID(), number: 1, startDate: completedTrayStart, plannedDays: 2)
        let completedNow = calendar.date(from: DateComponents(year: 2026, month: 2, day: 12, hour: 8))!

        let outStart = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10, hour: 8))!
        let outEnd = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10, hour: 16))!
        let highDeficitSession = RemovalSession(id: UUID(), startTime: outStart, endTime: outEnd)

        XCTAssertTrue(
            TrackerCalculator.isEligibleForOneDayExtension(
                tray: completedTray,
                sessions: [highDeficitSession],
                targetMinutes: 22 * 60,
                thresholdMinutes: 5 * 60,
                now: completedNow
            )
        )

        let activeTrayStart = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10))!
        let activeTray = Tray(id: UUID(), number: 2, startDate: activeTrayStart, plannedDays: 15)
        let earlyNow = calendar.date(from: DateComponents(year: 2026, month: 2, day: 11, hour: 8))!

        XCTAssertFalse(
            TrackerCalculator.isEligibleForOneDayExtension(
                tray: activeTray,
                sessions: [highDeficitSession],
                targetMinutes: 22 * 60,
                thresholdMinutes: 5 * 60,
                now: earlyNow
            )
        )
    }

    private func mockSession(day: Date, outMinutes: Int) -> RemovalSession {
        let start = DateService.calendar.date(byAdding: .hour, value: 8, to: day)!
        let end = DateService.calendar.date(byAdding: .minute, value: outMinutes, to: start)!
        return RemovalSession(id: UUID(), startTime: start, endTime: end)
    }
}
