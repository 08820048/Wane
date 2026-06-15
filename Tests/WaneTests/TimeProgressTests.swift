import XCTest
@testable import WaneCore

final class TimeProgressTests: XCTestCase {
    func testWorkdayProgressClampsBeforeStartAndAfterEnd() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let beforeStart = calendar.date(from: DateComponents(year: 2026, month: 6, day: 15, hour: 8))!
        let afterEnd = calendar.date(from: DateComponents(year: 2026, month: 6, day: 15, hour: 19))!

        let start = TimeOfDay(hour: 9, minute: 0)
        let end = TimeOfDay(hour: 18, minute: 0)

        XCTAssertEqual(
            TimeProgress.progress(for: .today, now: beforeStart, calendar: calendar, workStart: start, workEnd: end).progress,
            0
        )
        XCTAssertEqual(
            TimeProgress.progress(for: .today, now: afterEnd, calendar: calendar, workStart: start, workEnd: end).progress,
            1
        )
    }

    func testWorkdayProgressAtMiddleOfDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let now = calendar.date(from: DateComponents(year: 2026, month: 6, day: 15, hour: 13, minute: 30))!
        let progress = TimeProgress.progress(
            for: .today,
            now: now,
            calendar: calendar,
            workStart: TimeOfDay(hour: 9, minute: 0),
            workEnd: TimeOfDay(hour: 18, minute: 0)
        )

        XCTAssertEqual(progress.progress, 0.5, accuracy: 0.0001)
    }

    func testWeekUsesMondayAsStart() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let mondayNoon = calendar.date(from: DateComponents(year: 2026, month: 6, day: 15, hour: 12))!
        let progress = TimeProgress.progress(for: .week, now: mondayNoon, calendar: calendar)

        XCTAssertEqual(progress.detail, "Day 1 of 7")
        XCTAssertEqual(progress.progress, 0.0714, accuracy: 0.001)
    }
}
